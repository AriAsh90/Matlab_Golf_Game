% Golf game - Created by Ariel Ashkenazy
% Last modified - 6/28/2020
function varargout = golf(varargin)
    % GOLF MATLAB code for golf.fig
    %      GOLF, by itself, creates a new GOLF or raises the existing
    %      singleton*.
    %
    %      H = GOLF returns the handle to a new GOLF or the handle to
    %      the existing singleton*.
    %
    %      GOLF('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GOLF.M with the given input arguments.
    %
    %      GOLF('Property','Value',...) creates a new GOLF or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before golf_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to golf_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help golf

    % Last Modified by GUIDE v2.5 12-Aug-2015 15:00:05

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @golf_OpeningFcn, ...
                       'gui_OutputFcn',  @golf_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT

% --- Executes just before golf is made visible.
function golf_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to golf (see VARARGIN)

    % Choose default command line output for golf
    handles.output = hObject;
    handles.isStart=1; %flag for first Start button press
    handles.minpoint=500;
    handles.isRandom=1; %flag if hole position is random or fixed
    handles.gamepts=0;
    handles.lvl=1;
    handles.ptsperhit=handles.minpoint;
    handles.fcoefMin=0.1; 
    handles.fcoefMax=0.6;
    handles.fcoef=0.35;
    handles.maxVelocity=70+(handles.fcoef-handles.fcoefMin)*(30/(handles.fcoefMax-handles.fcoefMin)); %formula can be adjusted
    handles.holemaxsize=3;
    handles.holeRad=handles.holemaxsize;
    handles.BallRad=2/3;
    handles.teta=0;
    handles.velocity=0;
    set(handles.ContinueTxt,'Visible','off','Enable','on');
    set(handles.GamePts,'string',num2str(handles.gamepts));
    set(handles.PtsPerHit,'string',num2str(handles.ptsperhit));
    set(handles.fMin,'string',num2str(handles.fcoefMin));
    set(handles.fMax,'string',num2str(handles.fcoefMax));
    set(handles.fSlide,'Value',handles.fcoef);
    set(handles.fSlide,'Min',handles.fcoefMin,'Max',handles.fcoefMax);
    set(handles.fCoef,'string',num2str(handles.fcoef));
    set(handles.EndBtn,'Enable','off');
    set(handles.GameSurface,'Color','g');
    handles.timer = timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 0.5, ...                        % Initial period is 0.5 sec.
        'TimerFcn', {@update_points,hObject}); % Specify callback function
    set(handles.speedText,'string','');
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes golf wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = golf_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;

% --- Executes on button press in StartBtn.
function StartBtn_Callback(hObject, eventdata, handles)
    % hObject    handle to StartBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    set(handles.GamePts,'string',num2str(handles.gamepts));
    set(handles.ContinueTxt,'String',sprintf('Nice shot!\n\nPress start to continue\n\nPress end to quit game'));
    set(handles.ContinueTxt,'Visible','off');
    set(handles.GamePts,'ForegroundColor','k');
    set(handles.StartBtn,'Enable','off');
    set(handles.EndBtn,'Enable','on');
    set(handles.EasyBtn,'Enable','off');
    set(handles.MediumBtn,'Enable','off');
    set(handles.HardBtn,'Enable','off');
    set(handles.fSlide,'Enable','off');
    set(handles.timer,'TimerFcn',{@update_points,hObject},'Period',0.5);
    handles.teta=0;
    handles.velocity=0;
    handles.xmin=0;
    handles.xmax=100;
    handles.ymin=0;
    handles.ymax=100;
    handles.ballpos=[handles.xmin+3*handles.BallRad,(handles.ymax-handles.ymin)/2];
    handles.holepos=[,];
    buildGame(hObject,handles);
    handles=guidata(hObject);
    set(handles.GameSurface,'SortMethod','childorder');
    start(handles.timer);
    set(handles.GameSurface,'ButtonDownFcn',@hit);
    set(handles.figure1,'WindowButtonMotionFcn',@speed);
    handles.isStart=0;
    guidata(hObject, handles);

function buildGame(hObject,handles)
    teta=linspace(0,2*pi,100);
    x=handles.BallRad*cos(teta);
    y=handles.BallRad*sin(teta);
    if(handles.isStart)
        handles.ball=fill(x+handles.ballpos(1),y+handles.ballpos(2),'w');        
    else
        set(handles.ball,'XData',x+handles.ballpos(1),'YData',y+handles.ballpos(2));     
    end   
    hold on
    set(handles.GameSurface,'Color','g');
    set(handles.GameSurface,'XLim',[handles.xmin,handles.xmax]);
    set(handles.GameSurface,'YLim',[handles.ymin,handles.ymax]);
    x=handles.holeRad*cos(teta);
    y=handles.holeRad*sin(teta);
    if(handles.isRandom)
        handles.holepos=[0.8*handles.xmax+3*handles.BallRad+(handles.xmax-3*handles.BallRad-0.8*handles.xmax-3*handles.BallRad)*rand(1),...
            handles.ymin+3*handles.BallRad+(handles.ymax-3*handles.BallRad-handles.ymin-3*handles.BallRad)*rand(1)];
    else
        handles.holepos=[90,50];
    end
    if(handles.isStart)
        handles.hole=fill(x+handles.holepos(1),y+handles.holepos(2),'k','HitTest','off');
    else
        set(handles.hole,'XData',x+handles.holepos(1),'YData',y+handles.holepos(2));
    end
    handles.speedVect=line('XData',[],'YData',[],'Marker','.','color','r','HitTest','off');
    handles.speedTextLine=text(25,25,'','HitTest','off');
    guidata(hObject, handles);
    
function update_points(hObject,eventdata,hfigure) %timer function, subtracts 5 pts for ever 0.5 sec
    handles = guidata(hfigure);
    if(handles.ptsperhit>5)
        handles.ptsperhit=handles.ptsperhit-5; %formula can be adjusted
        set(handles.PtsPerHit,'string',num2str(handles.ptsperhit));
        guidata(hfigure, handles);
    end
        
function speed(src,evnt) %controls speed arrow 
    handles=guidata(src);
    cpGame=get(handles.GameSurface,'CurrentPoint');
    xn=cpGame(1,1); yn=cpGame(1,2);
    x=xn-handles.ballpos(1);
    y=yn-handles.ballpos(2);
    xdat=[handles.ballpos(1),xn-0.5*0.01*(handles.xmax-handles.xmin)*sign(x)]; %placing of arrow can be adjusted
    ydat=[handles.ballpos(2),yn-0.5*0.01*(handles.ymax-handles.ymin)*sign(y)]; %placing of arrow can be adjusted
    set(handles.speedVect,'XData',xdat,'YData',ydat);
    if x>=0 %determine teta
        if y>=0
            handles.teta=atan(y/x);
        else
            y=-y;
            handles.teta=-atan(y/x);
        end
    else
        if y>=0
            x=-x;
            handles.teta=pi-atan(y/x);
        else
            x=-x;
            y=-y;
            handles.teta=-pi+atan(y/x);
        end
    end
    set(handles.speedText,'Visible','on');
    tetadeg=180/pi*handles.teta;
    tetatext=num2str(round(tetadeg,5,'significant'));
    handles.velocity=sqrt(x^2+y^2);
    if(handles.velocity>handles.maxVelocity) %maxVelocity cannot be exceeded
       handles.velocity=handles.maxVelocity;
       set(handles.speedText,'ForegroundColor','r'); %if maxVelocity then speed text turn red
       set(handles.speedTextLine,'Color','r');
    else
        set(handles.speedText,'ForegroundColor','k');
        set(handles.speedTextLine,'Color','k');
    end
    vtext=num2str(round(handles.velocity,5,'significant'));
    set(handles.speedTextLine,'position',[xn,yn]+...
        0.005*[(handles.xmax-handles.xmin)*sign(x),(handles.ymax-handles.ymin)*sign(y)]);
    set(handles.speedTextLine,'String',vtext,'Rotation',...
        tetadeg-180*(tetadeg>90)+180*(tetadeg<-90));
    set(handles.speedText,'string',['Teta=' tetatext ' Velocity=' vtext]);
    guidata(src,handles);
      
function hit(src,evnt) %function for ball hit
    handles=guidata(src);
    stop(handles.timer);
    set(handles.speedVect,'XData',[],'YData',[]);
    set(handles.speedText,'Visible','off');
    set(handles.speedTextLine,'String','');
    set(handles.GameSurface,'ButtonDownFcn','');
    set(handles.figure1,'WindowButtonMotionFcn','');
    handles.axisVelocity(1)=handles.velocity*cos(handles.teta);
    handles.axisVelocity(2)=handles.velocity*sin(handles.teta);
    handles.Acc(1)=3.5*handles.fcoef*9.8*cos(handles.teta); %determines acceleration, 
                                                            %a=miu*g where miu=3.5*fcoef (formula can be adjusted)
    handles.Acc(2)=3.5*handles.fcoef*9.8*sin(handles.teta);
    guidata(src,handles);
    set(handles.timer,'TimerFcn',{@running,src},'Period',0.033);
    start(handles.timer);
    
function running(hObject,eventdata,hfigure) %display of ball movement
    handles=guidata(hfigure);
    period=get(handles.timer,'Period');
    handles.axisVelocity=handles.axisVelocity-handles.Acc*period;
    handles.velocity=sqrt((handles.axisVelocity(1))^2 +(handles.axisVelocity(2))^2);
    handles.ballpos=handles.ballpos+handles.axisVelocity*period;
    teta=linspace(0,2*pi,100);
    x=handles.BallRad*cos(teta);
    y=handles.BallRad*sin(teta);
    set(handles.ball,'XData',x+handles.ballpos(1),'YData',y+handles.ballpos(2)); 
    isHit=sqrt((handles.ballpos(1)-handles.holepos(1))^2+(handles.ballpos(2)-handles.holepos(2))^2)<=handles.holeRad;
    isHit=isHit&&(abs(handles.axisVelocity(1))<=abs((50+(handles.fcoefMax-handles.fcoef)*(250/(handles.fcoefMax-handles.fcoefMin)))...
        *period*handles.Acc(1)));
    if(isHit) %check if ball hit hole
        stop(handles.timer);
        handles.gamepts=handles.gamepts+handles.ptsperhit;
        handles.ptsperhit=handles.minpoint*handles.lvl;
        set(handles.GamePts,'string',num2str(handles.gamepts));
        set(handles.PtsPerHit,'string',num2str(handles.ptsperhit));
        set(handles.ContinueTxt,'Visible','on');
        set(handles.StartBtn,'Enable','on');
    else if(abs(handles.axisVelocity(1))<=abs(handles.Acc(1)*period)) %check if motion stops
            stop(handles.timer);
            checkForLess=1;
            while((handles.ballpos(1)>=handles.xmax)||(handles.ballpos(2)>=handles.ymax))% determine axis limits
                handles.xmax=handles.xmax+50;
                handles.ymax=handles.ymax+50;
                checkForLess=0;
            end
            while(checkForLess&&(handles.xmax~=100)&&(handles.ballpos(1)<=handles.xmax-50)&&(handles.ballpos(2)<=handles.ymax-50))
                    handles.xmax=handles.xmax-50;
                    handles.ymax=handles.ymax-50;                    
            end 
            checkForMore=1;
            while((handles.ballpos(1)<=handles.xmin)||(handles.ballpos(2)<=handles.ymin))
                handles.xmin=handles.xmin-50;
                handles.ymin=handles.ymin-50;
                checkForMore=0;
            end
            while(checkForMore&&(handles.xmin~=0)&&(handles.ballpos(1)>=handles.xmin+50)&&(handles.ballpos(2)>=handles.ymin+50))
                    handles.xmin=handles.xmin+50;
                    handles.ymin=handles.ymin+50;
            end                
            if((handles.xmin<=-1000)||(handles.ymin<=-1000)||(handles.xmax>=1000)||(handles.ymax>=1000))% checks if ball out of bounds
                stop(handles.timer);               
                set(handles.ContinueTxt,'String',sprintf('\nBall out of bounds\n\n\n press start to continue'));
                set(handles.ContinueTxt,'Visible','on');
                set(handles.StartBtn,'Enable','on');
            else
                set(handles.GameSurface,'XLim',[handles.xmin,handles.xmax]); %adjust axis limits
                set(handles.GameSurface,'YLim',[handles.ymin,handles.ymax]);
                set(handles.timer,'TimerFcn',{@update_points,hfigure},'Period',0.5);
                start(handles.timer);
                set(handles.GameSurface,'ButtonDownFcn',@hit);
                set(handles.figure1,'WindowButtonMotionFcn',@speed);
            end
        end
    end
    guidata(hfigure,handles);
        
% --- Executes on button press in EndBtn.
function EndBtn_Callback(hObject, eventdata, handles) 
% hObject    handle to EndBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.timer, 'Running'), 'on')
    stop(handles.timer);
end
set(handles.ContinueTxt,'String',sprintf('Game Over!\n\nWanna play again?\n\nChoose game settings and press start'));
set(handles.ContinueTxt,'Visible','on');
set(handles.GamePts,'ForegroundColor','r');
set(handles.StartBtn,'Enable','on');
set(handles.EndBtn,'Enable','off');
handles.gamepts=0;
set(handles.EasyBtn,'Enable','on');
set(handles.MediumBtn,'Enable','on');
set(handles.HardBtn,'Enable','on');
set(handles.fSlide,'Enable','on');
set(handles.speedVect,'XData',[],'YData',[]);
set(handles.GameSurface,'ButtonDownFcn','');
set(handles.figure1,'WindowButtonMotionFcn','');
set(handles.speedText,'Visible','off');
set(handles.speedTextLine,'String','');
handles.ptsperhit=handles.minpoint*handles.lvl;
guidata(hObject, handles);

% --- Executes when selected object is changed in Difficultygroup.
function Difficultygroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Difficultygroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
chs=eventdata.NewValue;
switch chs
    case handles.EasyBtn
        handles.lvl=1;
    case handles.MediumBtn
        handles.lvl=2;
    case handles.HardBtn
        handles.lvl=3;   
end
handles.ptsperhit=handles.minpoint*handles.lvl; %formula can be adjusted
set(handles.PtsPerHit,'string',num2str(handles.ptsperhit));
handles.holeRad=handles.holemaxsize/handles.lvl; %formula can be adjusted
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function fSlide_Callback(hObject, eventdata, handles)
% hObject    handle to fSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.fcoef=get(hObject,'Value');
handles.maxVelocity=70+(handles.fcoef-handles.fcoefMin)*(30/(handles.fcoefMax-handles.fcoefMin)); %formula can be adjusted
set(handles.fCoef,'string',num2str(handles.fcoef));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if strcmp(get(handles.timer, 'Running'), 'on')
    stop(handles.timer);
end
delete(handles.timer);
delete(hObject);
