function varargout = gui(varargin)
    % Implementation for functionality of gui.fig
    % Initialization of values of text fields is done under gui_OpeningFcn
    % function.
    % Since there is only one button,
    % all other functionality is done under start_Callback
    % which consists of variables setting, calling to ga.m function
    % and the graph output.
    % Since interrupts are not possible in matlab without major
    % interference to the algorithm, stop button is not implemented, and
    % all values that are changed during run time are shown in the terminal
    % window and not in the gui itself.

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui (see VARARGIN)

    % Choose default command line output for gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes gui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    set(handles.initial_guess, 'enable', 'off');
    set(handles.mutation_chance_g, 'enable', 'off');
    set(handles.max_mutation_value_g, 'enable', 'off');
    set(handles.n, 'enable', 'off');
    set(handles.materials, 'string', '1, 1.38, 3.95, 2.45, 1.85');
    set(handles.wavelength, 'string', '500');
    set(handles.population_size, 'string', '1000');
    set(handles.l_min, 'string', '1');
    set(handles.l_step, 'string', '1');
    set(handles.l_max, 'string', '1000');
    set(handles.min_thickness, 'string', '400');
    set(handles.max_thickness, 'string', '1200');
    set(handles.crossover, 'string', '30');
    set(handles.mutation_chance, 'string', '0.01');
    set(handles.mutation_value, 'string', '50');
    set(handles.accuracy, 'string', '85');
    set(handles.initial_guess, 'string', '');
    set(handles.mutation_chance_g, 'string', '0.1');
    set(handles.max_mutation_value_g, 'string', '50');
    set(handles.n, 'string', '100');
end

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end
% -------------------------------------------------------------------------

function start_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function start_Callback(hObject, eventdata, handles)
    materials_list = str2num(get(handles.materials, 'String'));
    wavelength_list = str2num(get(handles.wavelength, 'String'));
    population_size = str2num(get(handles.population_size, 'String'));
    min_thickness = str2num(get(handles.min_thickness, 'String'));
    max_thickness = str2num(get(handles.max_thickness, 'String'));
    crossover_percent = str2num(get(handles.crossover, 'String'));
    mutation_chance = str2num(get(handles.mutation_chance, 'String'));
    max_mutation_value = str2num(get(handles.mutation_value, 'String'));
    accuracy = str2num(get(handles.accuracy, 'String'));
    use_initial_guess = get(handles.use_initial_guess, 'Value');
    if use_initial_guess == 1
        initial_guess = str2num(get(handles.initial_guess, 'String'));
        mutation_chance_g = str2num(get(handles.mutation_chance_g, 'String'));
        max_mutation_value_g = str2num(get(handles.max_mutation_value_g, 'String'));
        n = str2num(get(handles.n, 'String'));
    end
    if use_initial_guess == 0
        [optimal, t] = ga(materials_list, wavelength_list, population_size, min_thickness, max_thickness, crossover_percent, mutation_chance, max_mutation_value, accuracy)
    else
       [optimal, t] = ga(materials_list, wavelength_list, population_size, min_thickness, max_thickness, crossover_percent, mutation_chance, max_mutation_value, accuracy, initial_guess, mutation_chance_g, max_mutation_value_g, n)
    end
    min_l = str2num(get(handles.l_min, 'String'));
    max_l = str2num(get(handles.l_max, 'String'));
    step_l = str2num(get(handles.l_step, 'String'));
    lambda = min_l:step_l:max_l;
    Gamma = multidiel(materials_list, optimal, lambda);
    Gamma = abs(Gamma).^2;
    Gamma = log(Gamma);
    axes(handles.axes);
    plot(lambda, Gamma);
    xlabel('Lambda [nm]');
    ylabel('Log[Gamma^2]');
    grid on;
    set(handles.optimal_con, 'String', cellstr(num2str(optimal')));
    set(handles.run_time, 'String', t);
    fileID = fopen('history.txt','at');
    fprintf(fileID,'%19s','Chosen wavelength: ');
    fprintf(fileID,'%10.10f\n', wavelength_list);
    fprintf(fileID,'%19s\n','Chosen materials:');
    fprintf(fileID,'%10.10f\n', materials_list);
    fprintf(fileID,'%22s\n','Optimal thicknesses:');
    fprintf(fileID,'%10.10f\n', optimal);
    fprintf(fileID,'%14s %10.10f %9s\n','Running time: ', t, ' seconds.');
    fprintf(fileID,'------------------------------------------');
    fclose(fileID);
end
    
function use_initial_guess_Callback(hObject, eventdata, handles)
    use_initial_guess = get(handles.use_initial_guess, 'Value');
    if use_initial_guess == 0
        set(handles.initial_guess, 'enable', 'off');
        set(handles.mutation_chance_g, 'enable', 'off');
        set(handles.max_mutation_value_g, 'enable', 'off');
        set(handles.n, 'enable', 'off');
    end
    if use_initial_guess == 1
        set(handles.initial_guess, 'enable', 'on');
        set(handles.mutation_chance_g, 'enable', 'on');
        set(handles.max_mutation_value_g, 'enable', 'on');
        set(handles.n, 'enable', 'on');
    end
end

function materials_Callback(hObject, eventdata, handles)
end

function materials_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function wavelength_Callback(hObject, eventdata, handles)
end

function wavelength_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function population_size_Callback(hObject, eventdata, handles)
end

function population_size_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function l_min_Callback(hObject, eventdata, handles)
end

function l_min_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function l_step_Callback(hObject, eventdata, handles)
end

function l_step_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function l_max_Callback(hObject, eventdata, handles)
end

function l_max_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function min_thickness_Callback(hObject, eventdata, handles)
end

function min_thickness_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function max_thickness_Callback(hObject, eventdata, handles)
end

function max_thickness_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function crossover_Callback(hObject, eventdata, handles)
end

function crossover_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function mutation_chance_Callback(hObject, eventdata, handles)
end

function mutation_chance_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function mutation_value_Callback(hObject, eventdata, handles)
end

function mutation_value_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function accuracy_Callback(hObject, eventdata, handles)
end

function accuracy_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function initial_guess_Callback(hObject, eventdata, handles)
end

function initial_guess_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function mutation_chance_g_Callback(hObject, eventdata, handles)
end

function mutation_chance_g_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function max_mutation_value_g_Callback(hObject, eventdata, handles)
end

function max_mutation_value_g_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function n_Callback(hObject, eventdata, handles)
end

function n_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function run_time_Callback(hObject, eventdata, handles)
end

function run_time_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function optimal_con_Callback(hObject, eventdata, handles)
end

function optimal_con_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
