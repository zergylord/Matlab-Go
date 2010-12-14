% Copyright 2010 Kevin Weng, Nathan Koon, David Tam
% 
% This file is part of DKN Go.
% 
% DKN Go is free software: you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free Software 
% Foundation, either version 3 of the License, or (at your option) any later version.
% 
% DKN Go is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
% PARTICULAR PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with DKN Go. If not, see http://www.gnu.org/licenses/.

classdef Player < handle
    % player version 1.0 EVERYTHING WORKS
    properties
        Color
        Type = 'human';
        MyPieceList
        Game
        s2
        size
        lb
        urc
        cp
        AIexamineboard
        dielist
        Size
        neighborsofdoom
    end
    
    methods
        
        function h = Player(type,Color,game,size)
            h.Type = type;
            h.Color = Color;
            h.Game = game;
            h.MyPieceList = zeros(size);
            h.size = size;
            h.s2 = size*size;
            h.lb = h.size*h.size-h.size;
            h.urc = (h.size*h.size) - h.size + 1;
            h.Size=h.size;
        end
        
        function MakeMove(h,move)
            if ValidMove(move,h.MyPieceList)
                x = move(1);
                y = move(2);
                h.MyPieceList(x,y) = h.Color;
            else
                disp 'INVALID MOVE';
            end
        end
        
        function moveList = PossibleMoves(h,board)
            flatInds = find(board==0);
            NumPosMoves = length(flatInds);
            moveList = zeros(2,NumPosMoves);
            for i = 1:NumPosMoves
                x = ceil(flatInds(i)/h.size);
                if mod(flatInds(i),h.size)==0
                    y = h.size;
                else
                    y = mod(flatInds(i),h.size);
                end
                move = [x y];
                moveList(1,i) = x;
                moveList(2,i) = y;
            end
            if (length(find(moveList==0) > 0))
                error('zero found in possibleMoves')
            end
        end
        
        function flag = ValidMove(h,move)
            flag = true;
            x = move(1);
            y = move(2);
            if (h.MyPieceList(x,y) ~= 0)
                flag = false;
            end
        end
        
        
        function move = NextMove(h)
            % get list of current possible moves
            initMoves = h.PossibleMoves(h.MyPieceList);
            nummoves = numel(initMoves)/2;
            ngames = 5;
            games = zeros(h.size,h.size,nummoves,ngames);
            cp = h.Color;
            tic;
            disp 'Be patient. AI is thinking.';
            for m = 1:nummoves
                %posmove = m
                for game = 1:ngames
                    %disp 'Examining';
                    %game
                    % copy possible moves in and initialize number of moves
                    % left after doing prospective move
                    gMoveList = initMoves;
                    nMovesLeft = nummoves-1;
                    % copy curent board state into each game
                    games(:,:,m,game)=h.MyPieceList;
                    % make prospective move to each game to be examined
                    % and remove it from moveList
                    x = gMoveList(1,m);
                    y = gMoveList(2,m);
                    games(x,y,m,game)=h.Color;
                    gMoveList(:,m) = [];
                    % set current player to op and op to cp
                    if h.Color == 1
                        h.cp = 2;
                    elseif h.Color == 2
                        h.cp = 1;
                    end
                    op = h.Color;
                    g=games(:,:,m,game);
                    mCount = 1;
                    while (nMovesLeft > 10)
                        mCount = mCount + 1;
                        % get random move from list
                        randMove = ceil(rand*nMovesLeft);
                        x = gMoveList(1,randMove);
                        y = gMoveList(2,randMove);
                        % remove from list
                        gMoveList(:,randMove) = [];
                        h.AIexamineboard = games(:,:,m,game);
                        linInd = (x-1)*h.size+y;
                        if games(x,y,m,game)==0 & ~h.IsEye(linInd,h.AIexamineboard)
                            % make move
                            h.AIexamineboard(x,y)=h.cp;
                            % need to clean board ************************
                            h.cleanboardother;
                            h.cleanboardself;
                            games(:,:,m,game)=h.AIexamineboard;
                            % update current player
                            if h.cp == 1
                                h.cp = 2;
                                op = 1;
                            elseif h.cp ==2
                                h.cp = 1;
                                op = 2;
                            end
                        end
                        nMovesLeft = nMovesLeft - 1;
                        g=games(:,:,m,game);
                    end
                end
            end
            time = toc;
            
            mScores = zeros(1,nummoves);
            % tally score for boards
            for m = 1:nummoves
                s = 0;
                for game = 1:ngames
                    gamePieceList = games(:,:,m,game);
                    r = h.findWinner(gamePieceList);
                    if r == h.Color
                        s = s + 1;
                    end
                    %s = s + length(find(games(:,:,m,game)==h.Color));
                end
                mScores(m) = s;
            end
            %outScores = reshape(mScores,h.size,h.size)./ngames
            [maxVal ind]=max(mScores);
            x = initMoves(1,ind);
            y = initMoves(2,ind);
            move = [x y];
            if h.AllSingleEyes(h.MyPieceList)
                move = [-1 -1]
            end
            move
        end
        
        function eon = IsEye(h,i,PL)
            eon = false;
            nBors = getLinNbors(h,i,PL);
            if length(find(nBors == 2)) == 4 | length(find(nBors == 1)) == 4
                %disp('Signle eye found at:');
                %disp(blankSpots(i));
                eon = true;
            elseif length(find(nBors == 2)) == 2 & length(find(nBors == 3)) == 2
                %disp('Signle eye found at:');
                %disp(blankSpots(i));
                eon = true;
            elseif length(find(nBors == 1)) == 2 & length(find(nBors == 3)) == 2
                %disp('Signle eye found at:');
                %disp(blankSpots(i));
                eon =true;
            elseif length(find(nBors == 2)) == 3 & length(find(nBors == 3)) == 1
                %disp('Signle eye found at:');
                %disp(blankSpots(i));
                eon = true;
            elseif length(find(nBors == 1)) == 3 & length(find(nBors == 3)) == 1
                %disp('Signle eye found at:');
                %disp(blankSpots(i));
                eon = true;
            end
        end
        
        function allEyes=AllSingleEyes(h,PL)
            allEyes = false;
            eyeList = [];
            blankSpots = find(PL==0);
            eyeOrNot = zeros(length(blankSpots));
            for i = 1:length(blankSpots)
                nBors = h.getLinNbors(blankSpots(i),PL);
                if length(find(nBors == 2)) == 4 | length(find(nBors == 1)) == 4
                    %disp('Signle eye found at:');
                    %disp(blankSpots(i));
                    eyeOrNot(i) = 1;
                elseif length(find(nBors == 2)) == 2 & length(find(nBors == 3)) == 2
                    %disp('Signle eye found at:');
                    %disp(blankSpots(i));
                    eyeOrNot(i) = 1;
                elseif length(find(nBors == 1)) == 2 & length(find(nBors == 3)) == 2
                    %disp('Signle eye found at:');
                    %disp(blankSpots(i));
                    eyeOrNot(i) = 1;
                elseif length(find(nBors == 2)) == 3 & length(find(nBors == 3)) == 1
                    %disp('Signle eye found at:');
                    %disp(blankSpots(i));
                    eyeOrNot(i) = 1;
                elseif length(find(nBors == 1)) == 3 & length(find(nBors == 3)) == 1
                    %disp('Signle eye found at:');
                    %disp(blankSpots(i));
                    eyeOrNot(i) = 1;
                end
            end
            if length(find(eyeOrNot == 1)) == length(eyeOrNot)
                allEyes = true;
            end
        end
        
        function score = ScoreBoard(h,pieceList)
            pieceList
        end
        function nList = getLinNbors(h,x,PL)
            
            if x < h.size && x==1
                %%%%%%%%[L    R      T    B]
                nList = [3 PL(x+h.size) 3 PL(x+1)];
            elseif x == h.size
                nList = [3 PL(x+h.size) PL(x-1) 3];
            elseif x < h.size
                nList = [3 PL(x+h.size) PL(x-1) PL(x+1)];
            elseif x == h.urc
                nList = [PL(x-h.size) 3 3 PL(x+1)];
            elseif x == h.s2
                nList = [PL(x-h.size) 3 PL(x-1) 3];
            elseif x < h.s2 && x > h.lb
                nList = [PL(x-h.size) 3 PL(x-1) PL(x+1)];
            elseif rem(x,h.size) == 1
                nList = [PL(x-h.size) PL(x+h.size) 3 PL(x+1)];
            elseif rem(x,h.size) == 0
                nList = [PL(x-h.size) PL(x+h.size) PL(x-1) 3];
            else
                nList = [PL(x-h.size) PL(x+h.size) PL(x-1) PL(x+1)];
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %               SCORING FUNCTIONS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out = score(h,pieceList, i, j)
            % if blank
            if pieceList(i,j) == 0
                %check top
                if i == 1 && j ~= 1 && j ~= h.size
                    % do stuff
                    temp = zeros(3, 1);
                    temp(1) = pieceList(i, j+1);
                    temp(2) = pieceList(i, j-1);
                    temp(3) = pieceList(i+1, j);
                    % if all zeros and no neighbors
                    if temp(1:3) == zeros(3, 1);
                        winner = h.score(pieceList, i+1,j);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)&&(temp(3)==1||temp(3)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)&&(temp(3)==2||temp(3)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                    %check bottom
                elseif i == h.size && j~=1 && j~=h.size
                    temp = zeros(3, 1);
                    temp(1) = pieceList(i, j+1);
                    temp(2) = pieceList(i, j-1);
                    temp(3) = pieceList(i-1, j);
                    % if all zeros and no neighbors
                    if temp(1:3) == zeros(3, 1);
                        winner = h.score(pieceList, i-1,j);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)&&(temp(3)==1||temp(3)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)&&(temp(3)==2||temp(3)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                    %check left
                elseif j == 1 && i~=1 && i~=h.size
                    temp = zeros(3, 1);
                    temp(1) = pieceList(i+1, j);
                    temp(2) = pieceList(i-1, j);
                    temp(3) = pieceList(i, j+1);
                    % if all zeros and no neighbors
                    if temp(1:3) == zeros(3, 1);
                        winner = h.score(pieceList, i,j+1);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)&&(temp(3)==1||temp(3)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)&&(temp(3)==2||temp(3)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                    %check right
                elseif j == h.size && i~=1 && i~=h.size
                    temp = zeros(3, 1);
                    temp(1) = pieceList(i+1, j);
                    temp(2) = pieceList(i-1, j);
                    temp(3) = pieceList(i, j-1);
                    % if all zeros and no neighbors
                    if temp(1:3) == zeros(3, 1);
                        winner = h.score(pieceList, i,j-1);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)&&(temp(3)==1||temp(3)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)&&(temp(3)==2||temp(3)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                    %check corners
                elseif j == 1 && i == 1
                    temp = zeros(2, 1);
                    temp(1) = pieceList(i+1, j);
                    temp(2) = pieceList(i, j+1);
                    % if all zeros and no neighbors
                    if temp(1:2) == zeros(2, 1);
                        winner = h.score(pieceList, i+1,j);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                elseif j == 1 && i == h.size % bottom left
                    temp = zeros(2, 1);
                    temp(1) = pieceList(i-1, j);
                    temp(2) = pieceList(i, j+1);
                    % if all zeros and no neighbors
                    if temp(1:2) == zeros(2, 1);
                        winner = h.score(pieceList, i-1,j);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                elseif j == h.size && i == 1 % top right
                    temp = zeros(2, 1);
                    temp(1) = pieceList(i+1, j);
                    temp(2) = pieceList(i, j-1);
                    % if all zeros and no neighbors
                    if temp(1:2) == zeros(2, 1);
                        winner = h.score(pieceList, i+1,j);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                elseif j == h.size && i == h.size % bottom right
                    temp = zeros(2, 1);
                    temp(1) = pieceList(i-1, j);
                    temp(2) = pieceList(i, j-1);
                    % if all zeros and no neighbors
                    if temp(1:2) == zeros(2, 1);
                        winner = h.score(pieceList, i-1,j);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                else % not edge or corner
                    temp = zeros(4, 1);
                    temp(1) = pieceList(i, j+1);
                    temp(2) = pieceList(i, j-1);
                    temp(3) = pieceList(i+1, j);
                    temp(4) = pieceList(i-1, j);
                    % if all zeros and no neighbors
                    if temp(1:4) == zeros(4, 1);
                        winner = h.score(pieceList, i+1,j);
                    elseif (temp(1)==1||temp(1) == 0)&&(temp(2)==1||temp(2)==0)&&(temp(3)==1||temp(3)==0)&&(temp(4)==1||temp(4)==0)
                        % case: white or empty
                        winner = 1;
                    elseif (temp(1)==2||temp(1) == 0)&&(temp(2)==2||temp(2)==0)&&(temp(3)==2||temp(3)==0)&&(temp(4)==2||temp(4)==0)
                        winner = 2;
                    else
                        winner = 0;
                    end
                end
            else
                % not blank
                winner = pieceList(i,j);
            end
            out = winner;
        end
        
        function out = finalScore(h,pieceList)
            for i = 1:length(pieceList)
                for j = 1:length(pieceList)
                    award(i,j) = h.score(pieceList,i,j);
                end
            end
            out = award;
        end
        
        function out = findWinner(h,pieceList)
            award = h.finalScore(pieceList);
            ones = 0;
            twos = 0;
            for i = 1:h.size
                for j = 1:h.size
                    if award(i,j) == 1
                        ones = ones + 1;
                    elseif award(i,j) == 2
                        twos = twos + 1;
                    end
                end
            end
            if ones > twos
                out = 1;
            elseif ones < twos
                out = 2;
            else
                out = 0;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %              CLEANUP FUNCTIONS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function cleanboardother(h)
          
            %set up some temp variables
            if h.cp ==1
                CurrentPlayer = 1;
                OtherPlayer = 2;
            else
                CurrentPlayer=2;
                OtherPlayer = 1;
            end
            
            
            [listofx,listofy]=find(h.AIexamineboard==OtherPlayer);
            
            for i=1:length(listofx)
                h.dielist=[];
                amirightwhereiamatdead=h.cleanrecurseother([listofx(i) listofy(i)]);
                if amirightwhereiamatdead==0
                    currentmove = [listofx(i), listofy(i)];
                    h.dielist=[h.dielist;currentmove];
                    sizedielist = size(h.dielist);
                    for j=1:sizedielist(1)
                        if length(h.dielist)>0
                           h.AIexamineboard(h.dielist(j,1),h.dielist(j,2))=0;
                            %also kill current point
                            
                        end
                    end
                    
                    
                end
                
            end
            
            
            
        end
        function cleanboardself(h)
         
            %set up some temp variables
            %just reverse the order of players
            if h.cp ==1
                CurrentPlayer = 2;
                OtherPlayer = 1;
            else
                CurrentPlayer=1;
                OtherPlayer = 2;
            end
            
            
            [listofx,listofy]=find(h.AIexamineboard==OtherPlayer);
            
            for i=1:length(listofx)
                h.dielist=[];
                amirightwhereiamatdead=h.cleanrecurseself([listofx(i) listofy(i)]);
                if amirightwhereiamatdead==0
                    currentmove = [listofx(i), listofy(i)];
                    h.dielist=[h.dielist;currentmove];
                    sizedielist = size(h.dielist);
                    for j=1:sizedielist(1)
                        if length(h.dielist)>0
                           h.AIexamineboard(h.dielist(j,1),h.dielist(j,2))=0;
                            %also kill current point
                            
                        end
                    end
                    
                    
                end
                
            end
            
            
            
        end
        
        function alive=cleanrecurseother(h,nextpoint,looklist)
      
            
            
            if h.cp ==1
                CurrentPlayer = 1;
                OtherPlayer = 2;
            else
                CurrentPlayer=2;
                OtherPlayer = 1;
            end
            
            updatelooklist=0;
            if nargin==2
                
                findneighbors(h,nextpoint);
                
            else
                
                findneighbors(h,nextpoint,looklist);
                
                updatelooklist=1;
                
            end
            
            
            %now go through the neighbors and do stuff
            
            sizeneighborsofdoom = size(h.neighborsofdoom);
            stuffinneighbors=zeros(1,sizeneighborsofdoom(1));
            sizestuffinneighbors = size(stuffinneighbors);
            
            
          
            for j=1:sizestuffinneighbors(2)
                stuffinneighbors(j)=h.AIexamineboard(h.neighborsofdoom(j,1),h.neighborsofdoom(j,2));
            end %piece out if there is a player 1 or player 2 piece in current spot
            
            %if not totally surrounded
            for (p=1:length(stuffinneighbors))
                if stuffinneighbors(p)==0
                    
                    alive=1;
                end
            end
            
            if (length(h.neighborsofdoom)==0)
                alive=0;
            end
            
            
            
            if (stuffinneighbors>0) %if totally surrounded
                if (stuffinneighbors==h.cp) %if totally surrounded by opposite player
                    h.dielist=[h.dielist; nextpoint];
                    
                    %h.InternalBoard.Board(nextpoint(1),nextpoint(2))=0;
                    alive = 0;
                else
                    
                    %OMFG RECURSION TIME OF D000000000000MMMMMMM
                    %so you know that currentposition is surrounded
                    %you also know that currentposition has at least 1
                    %friendly around it
                    
                    %time to find location of friendly pieces
                    friendliesindex = (stuffinneighbors==OtherPlayer);
                    friendlieslocation = [];
                    
                    for z=1:length(friendliesindex)
                        if friendliesindex(z)==0
                            z=z+1;
                        else
                            friendlieslocation(z,1)=h.neighborsofdoom(z,1);
                            friendlieslocation(z,2)=h.neighborsofdoom(z,2);
                        end
                    end
                    
                    
                    
                    
                    
                    %used to strip out zero entries...hopefully this works
                    if sum(friendlieslocation==0)>0
                        
                        friendlieslocation=nonzeros(friendlieslocation);
                        friendlieslocation=reshape(friendlieslocation,[],2);
                    end
                    
                    
                    
                    
                    sizefriendlieslocation = size(friendlieslocation);
                    fate=[];
                    %NOW FOR THE CALLS OF RECURSSSIIOONNNN
                    
                    if updatelooklist
                        
                        nextpoint=[looklist;nextpoint];
                    end
                    
                    
                    for(c=1:sizefriendlieslocation(1))
                        fate(c)=cleanrecurseother(h,[friendlieslocation(c,1),friendlieslocation(c,2)],[nextpoint]);
                        
                    end
                    
                    
                    %managing what happens after you make the calls
                    
                    %                     %if the recursive calls out returns 0 ie dead, then
                    %                     %you're dead
                    if sum(fate)==0
                        alive = 0; %return dead if something called u
                        h.dielist=[h.dielist; nextpoint];
                        %otherwise, you're stillll aliveee
                    else
                        alive = 1;
                    end
                    
                    
                    
                end
            end
            
            
        end
        function alive=cleanrecurseself(h,nextpoint,looklist)
        
            %flip order of players to save rest of code
            if h.cp ==1
                CurrentPlayer = 2;
                OtherPlayer = 1;
            else
                CurrentPlayer=1;
                OtherPlayer = 2;
            end
            
            updatelooklist=0;
            if nargin==2
                
                findneighbors(h,nextpoint);
                
            else
                
                findneighbors(h,nextpoint,looklist)
                
                updatelooklist=1;
            end
            
            %now go through the neighbors and do stuff
            
            sizeneighborsofdoom = size(h.neighborsofdoom);
            stuffinneighbors=zeros(1,sizeneighborsofdoom(1));
            sizestuffinneighbors = size(stuffinneighbors);
            
            for j=1:sizestuffinneighbors(2)
                stuffinneighbors(j)=h.AIexamineboard(h.neighborsofdoom(j,1),h.neighborsofdoom(j,2));
            end %piece out if there is a player 1 or player 2 piece in current spot
            
            %if not totally surrounded
            for (p=1:length(stuffinneighbors))
                if stuffinneighbors(p)==0
                 
                    alive=1;
                end
            end
            if (length(h.neighborsofdoom)==0)
                alive=0;
            end
            
            
            
            if (stuffinneighbors>0) %if totally surrounded
                if (stuffinneighbors==CurrentPlayer) %if totally surrounded by opposite player
                    h.dielist=[h.dielist; nextpoint];
                
                    %h.InternalBoard.Board(nextpoint(1),nextpoint(2))=0;
                    alive = 0;
                else
                  
                    %OMFG RECURSION TIME OF D000000000000MMMMMMM
                    %so you know that currentposition is surrounded
                    %you also know that currentposition has at least 1
                    %friendly around it
                    
                    %time to find location of friendly pieces
                    friendliesindex = (stuffinneighbors==OtherPlayer);
                    friendlieslocation = [];
                    
                    for z=1:length(friendliesindex)
                        if friendliesindex(z)==0
                            z=z+1;
                        else
                            friendlieslocation(z,1)=h.neighborsofdoom(z,1);
                            friendlieslocation(z,2)=h.neighborsofdoom(z,2);
                        end
                    end
                    
                    
                    
                    
                    %used to strip out zero entries...hopefully this works
                    if sum(friendlieslocation==0)>0
                        
                        friendlieslocation=nonzeros(friendlieslocation);
                        friendlieslocation=reshape(friendlieslocation,[],2);
                    end
                    
                    
                    
                    
                    sizefriendlieslocation = size(friendlieslocation);
                    fate=[];
                    %NOW FOR THE CALLS OF RECURSSSIIOONNNN
                    
                    if updatelooklist
                        
                        nextpoint=[looklist;nextpoint];
                    end
               
                    for(c=1:sizefriendlieslocation(1))
                        fate(c)=cleanrecurseself(h,[friendlieslocation(c,1),friendlieslocation(c,2)],[nextpoint]);
                        
                    end
                    
                    %managing what happens after you make the calls
                    
                    %                     %if the recursive calls out returns 0 ie dead, then
                    %                     %you're dead
                    if sum(fate)==0
                        alive = 0; %return dead if something called u
                        h.dielist=[h.dielist; nextpoint];
                        %otherwise, you're stillll aliveee
                    else
                        alive = 1;
                    end
                    
                    
                    
                end
            end
            
            
        end
        function findneighbors(h,currentpoint,dontlookback)
            
            if nargin==2
                %you don't have a looklist
                %then self search for neighbors
                
                %check corner
                if (currentpoint(1)==1&&currentpoint(2)==1)
                    %top left corner
                    h.neighborsofdoom = [2 1; 1 2];
                elseif(currentpoint(1)==1&&currentpoint(2)==h.Size)
                    %top right corner
                    h.neighborsofdoom = [1 h.Size-1; 2 h.Size];
                elseif(currentpoint(1)==h.Size&&currentpoint(2)==1)
                    %bottom left corner
                    h.neighborsofdoom = [h.Size-1 1; h.Size 2];
                elseif(currentpoint(1)==h.Size&&currentpoint(2)==h.Size)
                    %bottom right corner
                    h.neighborsofdoom = [h.Size h.Size-1; h.Size-1 h.Size];
                    
                    %check edges
                elseif(currentpoint(1)==1)
                    %top edge
                    h.neighborsofdoom = [1 currentpoint(2)-1; 2 currentpoint(2); 1 currentpoint(2)+1];
                elseif(currentpoint(1)==h.Size)
                    %bottom edge
                    h.neighborsofdoom = [h.Size currentpoint(2)-1; h.Size-1 currentpoint(2); h.Size currentpoint(2)+1];
                elseif(currentpoint(2)==1)
                    %left edge
                    h.neighborsofdoom = [currentpoint(1)-1 1; currentpoint(1) 2; currentpoint(1)+1 1];
                elseif(currentpoint(2)==h.Size)
                    %right edge
                    h.neighborsofdoom = [currentpoint(1)-1 h.Size; currentpoint(1) h.Size-1; currentpoint(1)+1 h.Size];
                    
                else
                    %it's in the middle somewhere
                    %otherwise you're boringly in the middle
                    h.neighborsofdoom = [currentpoint(1)-1 currentpoint(2); currentpoint(1)+1 currentpoint(2); currentpoint(1) currentpoint(2)+1; currentpoint(1) currentpoint(2)-1];
                end
                
            else
                %yay, looklist time!
                if (currentpoint(1)==1&&currentpoint(2)==1)
                    %top left corner
                    potentialneighbors = [2 1; 1 2];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                    
                    
                    
                elseif(currentpoint(1)==1&&currentpoint(2)==h.Size)
                    %top right corner
                    potentialneighbors= [1 h.Size-1; 2 h.Size];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(1)==h.Size&&currentpoint(2)==1)
                    %bottom left corner
                    potentialneighbors= [h.Size-1 1; h.Size 2];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(1)==h.Size&&currentpoint(2)==h.Size)
                    %bottom right corner
                    potentialneighbors = [h.Size h.Size-1; h.Size-1 h.Size];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                    
                    %check edges
                elseif(currentpoint(1)==1)
                    %top edge
                    potentialneighbors = [1 currentpoint(2)-1; 2 currentpoint(2); 1 currentpoint(2)+1];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(1)==h.Size)
                    %bottom edge
                    potentialneighbors = [h.Size currentpoint(2)-1; h.Size-1 currentpoint(2); h.Size currentpoint(2)+1];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(2)==1)
                    %left edge
                    potentialneighbors = [currentpoint(1)-1 1; currentpoint(1) 2; currentpoint(1)+1 1];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(2)==h.Size)
                    %right edge
                    potentialneighbors = [currentpoint(1)-1 h.Size; currentpoint(1) h.Size-1; currentpoint(1)+1 h.Size];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                    
                else
                    %it's in the middle somewhere
                    %otherwise you're boringly in the middle
                    potentialneighbors = [currentpoint(1)-1 currentpoint(2); currentpoint(1)+1 currentpoint(2); currentpoint(1) currentpoint(2)+1; currentpoint(1) currentpoint(2)-1];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                end
            end
        end
        
        
        function neighborssuck=actualneighbors(h,dontlookback,potential)
            sizeA=size(dontlookback);
            sizeB=size(potential);
            neighborssuck=[];
            for i=1:sizeB(1)
                isunique=0;
                for j=1:sizeA(1)
                    if(sum(potential(i,:)~=dontlookback(j,:))>0)
                        isunique=isunique+1;
                    end
                end
                if isunique>=sizeA(1)
                    neighborssuck=[neighborssuck; potential(i,:)];
                end
            end
        end
        
    
    end
end
