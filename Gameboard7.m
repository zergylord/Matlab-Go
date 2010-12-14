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

classdef Gameboard7 < handle
    properties
        boardAxesH
        pieceList
        patchList
        size
        pass
        startButton
        endButton
        resetButton
        p
        award
        turn
        player1Select
        player2Select
        sizeSelect
        dielist
        lookedList
        neighborsofdoom
        ai1 = 0
        ai2 = 0
    end
    methods
        function h = Gameboard7()
            % create internal board of pieces
            h.p = 1;
            h.boardAxesH = axes;
            hold on;
            set(h.boardAxesH,'xtick',[],'ytick',[],'color',[0.858 0.6993 0.3593],'box','on')
            set(get(h.boardAxesH, 'parent'), 'position', [50, 100, 850, 700]);
            set(get(h.boardAxesH, 'parent'), 'menubar','none');
            axis square;
            h.startButton = uicontrol('style','pushbutton', 'position',[10 650 100 20],'str','New Game','fontname','papyrus','fontsize',10);
            h.pass = uicontrol('style','pushbutton', 'position',[10 620 100 20],'str','Pass','enable','off','fontname','papyrus','fontsize',10);
            h.endButton = uicontrol('style','pushbutton', 'position',[10 590 100 20],'str','End Game','enable','off','fontname','papyrus','fontsize',10);
            h.resetButton = uicontrol('style','pushbutton', 'position',[10 560 100 20],'str','Reset Game','enable','off','fontname','papyrus','fontsize',10);
            uicontrol('Style','Frame','Position',[10 480 100 70]);
            uicontrol('Style','Frame','Position',[10 400 100 70]);
            uicontrol('Style','Frame','Position',[10 320 100 70]);
            uicontrol('Style','Frame','Position',[10 240 100 70]);
            uicontrol('style','text','position',[17 525 85 20],'string', 'Select P1','fontname','papyrus','fontsize',10);
            uicontrol('style','text','position',[17 445 85 20],'string', 'Select P2','fontname','papyrus','fontsize',10);
            uicontrol('style','text','position',[17 365 85 20],'string', 'Select Size','fontname','papyrus','fontsize',10);
            h.turn = uicontrol('style','text','position',[17 285 85 20],'string', '','fontname','papyrus','fontsize',10);
            h.player1Select = uicontrol('Style','PopupMenu', 'Position',[15 505 90 10],'String',{'Human';'AI'});
            h.player2Select = uicontrol('Style','PopupMenu', 'Position',[15 425 90 10],'String',{'Human';'AI'});
            h.sizeSelect = uicontrol('Style','PopupMenu', 'Position',[15 345 90 10],'String',{'7 x 7';'9 x 9';'13 x 13';'19 x 19'});
            titleH = get(h.boardAxesH,'title');
            set(titleH,'String','Team DKN Presents: GO','fontname','papyrus');
            set(h.startButton, 'CallBack', {@start h});
            h.size = 1;
            h.pieceList = zeros(h.size);
            h.award = zeros(h.size);
            h.patchList = zeros(h.size);
            %h.dielist= [];
            h.lookedList=[];
            labelStr = '<html><center><a href="">Help<br>Click Here';
            cbStr = 'web(''http://en.wikipedia.org/wiki/Go_(game)'');';
            hButton = uicontrol('string',labelStr,'pos',[10,20,100,35],'callback',cbStr);
            %jButton = findjobj(hButton); % get FindJObj from the File Exchange
            %jButton.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            %jButton.setContentAreaFilled(0); % or: jButton.setBorder([]);
        end
        
        function click(ESrc, EData, h, i, j)
            if h.p == 1 && get(h.player1Select,'value') == 1 %current player = 1, and player1 = human
                updateBoard(h,i,j);
            elseif h.p == 2 && get(h.player2Select,'value') == 1 %current player = 2, and player2 = human
                updateBoard(h,i,j);
            end
            % GAMEFUNCTION(i, j);
        end
        
        function erMessage(ESR, EData, h, i, j)
            %display cannot place a piece here
            helpdlg(['Cannot place a piece here!'],'Error');
            
        end
        
        function start(ESR, EData, h)
            cla;
            % get size information
            if get(h.sizeSelect,'value') == 1
                h.size = 7;
            elseif get(h.sizeSelect,'value') == 2
                h.size = 9;
            elseif get(h.sizeSelect,'value') == 3
                h.size = 13;
            else
                h.size = 19;
            end
            h.p = 1;
            set(h.turn,'string','Player 1s turn');
            h.pieceList = zeros(h.size);
            h.award = zeros(h.size);
            %h.dieList = [];
            h.lookedList = [];
            tick = linspace(1,h.size,h.size);
            tick = tick';
            set(h.boardAxesH,'YGrid','on');
            set(h.boardAxesH,'Xgrid','on');
            set(h.boardAxesH,'gridlinestyle','-');
            set(h.boardAxesH,'YTick',tick);
            set(h.boardAxesH,'XTick',tick);
            set(h.boardAxesH,'xlim',[0.6 h.size+0.4],'ylim',[0.6 h.size+0.4]);
            for i = 1:h.size
                for j = 1:h.size
                    %create patches on crosses of grid
                    h.patchList(i,j) = patch([i-0.4 i-0.4*cos(pi()/6) i-0.2 i i+0.2 i+0.4*cos(pi()/6) i+0.4 i+0.4*cos(pi()/6) i+0.2 i i-0.2 i-0.4*cos(pi()/6)], [j j-0.2 j-0.4*cos(pi()/6) j-0.4 j-0.4*cos(pi()/6) j-0.2 j j+0.2 j+0.4*cos(pi()/6) j+0.4 j+0.4*cos(pi()/6) j+0.2],[1 1 1]);
                    set(h.patchList(i,j),'Visible','on');
                    set(h.patchList(i,j),'facecolor',[0.7 0.7 0.5]);
                    set(h.patchList(i,j),'edgecolor',[0 0 0]);
                    set(h.patchList(i,j),'facealpha',0);
                    set(h.patchList(i,j),'edgealpha',0);
                    set(h.patchList(i,j),'ButtonDownFcn', {@click h i j});
                end
            end
            set(h.pass, 'enable','on', 'callback',{@Pass h});
            set(h.endButton, 'enable','on', 'callback',{@endGame h});
            set(h.resetButton, 'enable','on', 'callback',{@resetGame h});
            set(h.player1Select,'enable','off');
            set(h.player2Select,'enable','off');
            display(['Starting game with ' int2str(h.size) ' by ' int2str(h.size) ' board']);
            if get(h.player2Select,'value') == 2 % if player2 is AI
                h.ai2 = Player('AI',2,h,h.size);
            end
            if get(h.player1Select,'value') == 2 % if player 1 is an AI
                %initialize AI
                h.ai1 = Player('AI',1,h,h.size);
                move = h.ai1.NextMove();
                updateBoard(h,move(2),move(1));
            end
        end
        
        function Pass(ESR, EData, h)
            if h.p == 1
                h.p = 2;
                set(h.turn,'string','Player 2s turn');
            elseif h.p == 2
                h.p = 1;
                set(h.turn,'string','Player 1s turn');
            end
        end
        
        function resetGame(ESR, EData, h)
            set(h.pass, 'enable','off');
            set(h.endButton, 'enable','off');
            set(h.player1Select,'enable','on');
            set(h.player2Select,'enable','on');
            h.pieceList = [];
            cla;
        end
        
        function endGame(ESR, EData, h)
            try
                finalScore(h);
                score = findWinner(h);
                if score(1) < score(2)
                    winner = 'Player 2';
                    out = 2;
                elseif score(1) > score(2)
                    winner = 'Player 1';
                    out = 1;
                else
                    winner = 'Nobody';
                    out = 0;
                end
                for i = 1:h.size
                    for j = 1:h.size
                        set(h.patchList(i,j),'Visible','on');
                        set(h.patchList(i,j),'ButtonDownFcn', {});
                    end
                end
                set(h.pass, 'enable','off');
                set(h.endButton, 'enable','off');
                set(h.player1Select,'enable','on');
                set(h.player2Select,'enable','on');
                helpdlg([winner ' won this match.'],'Result');
            catch
                helpdlg('The game has not ended and cannot be scored. To abandon game and start a new game, please press "Start Game"');
            end
        end
        
        function updateBoard(h,x,y)
            % change patch(x,y) to an image of 'color'
            % update pieceList
            % h.pieceList = pieces;
            if x == -1
                if h.p == 1
                    h.p = 2;
                else
                    h.p = 1;
                end
            else
            if h.p == 1
                h.pieceList(x,y) = 1;
            elseif h.p == 2
                h.pieceList(x,y) = 2;
            end
            if h.p==1
                otherP = 2;
            else
                otherP = 1;
            end
            h.cleanboardother;
            h.cleanboardself;
            sz = h.size;
            for i = 1:sz
                for j = 1:sz
                    % Set the pieces on the board accordingly
                    if h.pieceList(i,j) == 1
                        set(h.patchList(i,j),'facecolor',[0 0 0]);
                        set(h.patchList(i,j),'facealpha',1);
                        set(h.patchList(i,j),'ButtonDownFcn', {@erMessage h i j});
                    elseif h.pieceList(i,j) == 2
                        set(h.patchList(i,j),'facecolor',[1 1 1]);
                        set(h.patchList(i,j),'facealpha',1);
                        set(h.patchList(i,j),'ButtonDownFcn', {@erMessage h i j});
                    elseif h.pieceList(i,j) == 0
                        set(h.patchList(i,j),'facecolor',[0.7 0.7 0.5]);
                        set(h.patchList(i,j),'facealpha',0);
                        set(h.patchList(i,j),'ButtonDownFcn', {@click h i j});
                    end
                end
            end
            drawnow;
            if h.p == 1
                set(h.turn,'string','Player 2s turn');
                h.p = 2;
                drawnow;
                if get(h.player2Select,'value') == 2 % if player 2 = AI
                    %call ai for move
                    h.ai2.MyPieceList = h.pieceList;
                    move = h.ai2.NextMove();
                    updateBoard(h,move(2),move(1));
                end
            elseif h.p == 2
                set(h.turn,'string','Player 1s turn');
                h.p = 1;
                drawnow;
                if get(h.player1Select,'value') == 2 % if player 1 = AI
                    %call ai for move
                    h.ai1.MyPieceList = h.pieceList;
                    move = h.ai1.NextMove();
                    updateBoard(h,move(2),move(1));
                end
            end
            end
        end
        
        function out = findWinner(h)
            ones = 0;
            twos = 0;
            for i = 1:h.size
                for j = 1:h.size
                    if h.award(i,j) == 1
                        ones = ones + 1;
                    elseif h.award(i,j) == 2
                        twos = twos + 1;
                    end
                end
            end
            out = [ones twos];
        end
        
        function out = score(h, i, j)
            % if blank
            if h.pieceList(i,j) == 0
                %check top
                if i == 1 && j ~= 1 && j ~= h.size
                    % do stuff
                    temp = zeros(3, 1);
                    temp(1) = h.pieceList(i, j+1);
                    temp(2) = h.pieceList(i, j-1);
                    temp(3) = h.pieceList(i+1, j);
                    % if all zeros and no neighbors
                    if temp(1:3) == zeros(3, 1);
                        winner = score(h, i+1,j);
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
                    temp(1) = h.pieceList(i, j+1);
                    temp(2) = h.pieceList(i, j-1);
                    temp(3) = h.pieceList(i-1, j);
                    % if all zeros and no neighbors
                    if temp(1:3) == zeros(3, 1);
                        winner = score(h, i-1,j);
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
                    temp(1) = h.pieceList(i+1, j);
                    temp(2) = h.pieceList(i-1, j);
                    temp(3) = h.pieceList(i, j+1);
                    % if all zeros and no neighbors
                    if temp(1:3) == zeros(3, 1);
                        winner = score(h, i,j+1);
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
                    temp(1) = h.pieceList(i+1, j);
                    temp(2) = h.pieceList(i-1, j);
                    temp(3) = h.pieceList(i, j-1);
                    % if all zeros and no neighbors
                    if temp(1:3) == zeros(3, 1);
                        winner = score(h, i,j-1);
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
                    temp(1) = h.pieceList(i+1, j);
                    temp(2) = h.pieceList(i, j+1);
                    % if all zeros and no neighbors
                    if temp(1:2) == zeros(2, 1);
                        winner = score(h, i+1,j);
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
                    temp(1) = h.pieceList(i-1, j);
                    temp(2) = h.pieceList(i, j+1);
                    % if all zeros and no neighbors
                    if temp(1:2) == zeros(2, 1);
                        winner = score(h, i-1,j);
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
                    temp(1) = h.pieceList(i+1, j);
                    temp(2) = h.pieceList(i, j-1);
                    % if all zeros and no neighbors
                    if temp(1:2) == zeros(2, 1);
                        winner = score(h, i+1,j);
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
                    temp(1) = h.pieceList(i-1, j);
                    temp(2) = h.pieceList(i, j-1);
                    % if all zeros and no neighbors
                    if temp(1:2) == zeros(2, 1);
                        winner = score(h, i-1,j);
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
                    temp(1) = h.pieceList(i, j+1);
                    temp(2) = h.pieceList(i, j-1);
                    temp(3) = h.pieceList(i+1, j);
                    temp(4) = h.pieceList(i-1, j);
                    % if all zeros and no neighbors
                    if temp(1:4) == zeros(4, 1);
                        winner = score(h, i+1,j);
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
                winner = h.pieceList(i,j);
            end
            out = winner;
        end
        
        function finalScore(h)
            for i = 1:h.size
                for j = 1:h.size
                    h.award(i,j) = score(h,i,j);
                end
            end
        end
        
        % function delete(h)
        %    delete(h);
        % end
        %function display()
        %
        %end
        function cleanboardother(h)
           
            %set up some temp variables
            if h.p ==1
                CurrentPlayer = 1;
                OtherPlayer = 2;
            else
                CurrentPlayer=2;
                OtherPlayer = 1;
            end
            
            
            [listofx,listofy]=find(h.pieceList==OtherPlayer);
            
            for i=1:length(listofx)
                h.dielist=[];
                amirightwhereiamatdead=h.cleanrecurseother([listofx(i) listofy(i)]);
                if amirightwhereiamatdead==0
                    currentmove = [listofx(i), listofy(i)];
                    h.dielist=[h.dielist;currentmove];
                    sizedielist = size(h.dielist);
                    for j=1:sizedielist(1)
                        if length(h.dielist)>0
                            h.pieceList(h.dielist(j,1),h.dielist(j,2))=0;
                            %also kill current point
                            
                        end
                    end
                    
                    
                end
                
            end
            
            
            
        end
        function cleanboardself(h)
           
            %set up some temp variables
            %just reverse the order of players
            if h.p ==1
                CurrentPlayer = 2;
                OtherPlayer = 1;
            else
                CurrentPlayer=1;
                OtherPlayer = 2;
            end
            
            
            [listofx,listofy]=find(h.pieceList==OtherPlayer);
            
            for i=1:length(listofx)
                h.dielist=[];
                amirightwhereiamatdead=h.cleanrecurseself([listofx(i) listofy(i)]);
                if amirightwhereiamatdead==0
                    currentmove = [listofx(i), listofy(i)];
                    h.dielist=[h.dielist;currentmove];
                    sizedielist = size(h.dielist);
                    for j=1:sizedielist(1)
                        if length(h.dielist)>0
                            h.pieceList(h.dielist(j,1),h.dielist(j,2))=0;
                            %also kill current point
                            
                        end
                    end
                    
                    
                end
                
            end
            
            
            
        end
        
        function alive=cleanrecurseother(h,nextpoint,looklist)
          
            if h.p ==1
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
                
                findneighbors(h,nextpoint,looklist)
                
                updatelooklist=1;
                
            end
            
          
            %now go through the neighbors and do stuff
            
            sizeneighborsofdoom = size(h.neighborsofdoom);
            stuffinneighbors=zeros(1,sizeneighborsofdoom(1));
            sizestuffinneighbors = size(stuffinneighbors);
            
           
            for j=1:sizestuffinneighbors(2)
                stuffinneighbors(j)=h.pieceList(h.neighborsofdoom(j,1),h.neighborsofdoom(j,2));
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
                if (stuffinneighbors==h.p) %if totally surrounded by opposite player
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
            if h.p ==1
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
                stuffinneighbors(j)=h.pieceList(h.neighborsofdoom(j,1),h.neighborsofdoom(j,2));
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
                elseif(currentpoint(1)==1&&currentpoint(2)==h.size)
                    %top right corner
                    h.neighborsofdoom = [1 h.size-1; 2 h.size];
                elseif(currentpoint(1)==h.size&&currentpoint(2)==1)
                    %bottom left corner
                    h.neighborsofdoom = [h.size-1 1; h.size 2];
                elseif(currentpoint(1)==h.size&&currentpoint(2)==h.size)
                    %bottom right corner
                    h.neighborsofdoom = [h.size h.size-1; h.size-1 h.size];
                    
                    %check edges
                elseif(currentpoint(1)==1)
                    %top edge
                    h.neighborsofdoom = [1 currentpoint(2)-1; 2 currentpoint(2); 1 currentpoint(2)+1];
                elseif(currentpoint(1)==h.size)
                    %bottom edge
                    h.neighborsofdoom = [h.size currentpoint(2)-1; h.size-1 currentpoint(2); h.size currentpoint(2)+1];
                elseif(currentpoint(2)==1)
                    %left edge
                    h.neighborsofdoom = [currentpoint(1)-1 1; currentpoint(1) 2; currentpoint(1)+1 1];
                elseif(currentpoint(2)==h.size)
                    %right edge
                    h.neighborsofdoom = [currentpoint(1)-1 h.size; currentpoint(1) h.size-1; currentpoint(1)+1 h.size];
                    
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
                    
                    
                    
                elseif(currentpoint(1)==1&&currentpoint(2)==h.size)
                    %top right corner
                    potentialneighbors= [1 h.size-1; 2 h.size];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(1)==h.size&&currentpoint(2)==1)
                    %bottom left corner
                    potentialneighbors= [h.size-1 1; h.size 2];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(1)==h.size&&currentpoint(2)==h.size)
                    %bottom right corner
                    potentialneighbors = [h.size h.size-1; h.size-1 h.size];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                    
                    %check edges
                elseif(currentpoint(1)==1)
                    %top edge
                    potentialneighbors = [1 currentpoint(2)-1; 2 currentpoint(2); 1 currentpoint(2)+1];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(1)==h.size)
                    %bottom edge
                    potentialneighbors = [h.size currentpoint(2)-1; h.size-1 currentpoint(2); h.size currentpoint(2)+1];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(2)==1)
                    %left edge
                    potentialneighbors = [currentpoint(1)-1 1; currentpoint(1) 2; currentpoint(1)+1 1];
                    h.neighborsofdoom=h.actualneighbors(dontlookback,potentialneighbors);
                elseif(currentpoint(2)==h.size)
                    %right edge
                    potentialneighbors = [currentpoint(1)-1 h.size; currentpoint(1) h.size-1; currentpoint(1)+1 h.size];
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


