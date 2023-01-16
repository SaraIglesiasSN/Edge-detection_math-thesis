clear
I=imread('Data\Original\18a.jpg');   %Imagen original
F=imread('Data\Original\18b.jpg');    %Imagen Objetivo

paso=0.005;
sigmm = 0:paso:0.05;                                      %Varianza gaussiana

% Detectores 
functions = {@imdilate, @imerode};
names = ["dilat", "eros", "morph"];

% Matrices de Error
Err_mse_Robust=zeros(length(names),length(sigmm));

% Elemento estructurante
%SE = offsetstrel('ball',3,6);
SE = strel('square',3); % ancho de píxeles %PLANO

% Guardando detector en la imagen sin ruido
Folder_name0 = 'Data\Morphologic_detectors\Morphologic_det_og';
if ~exist(Folder_name0, 'dir')
        mkdir(Folder_name0);
end

%Detector en la imagen sin ruido
for i = 1:1:length(functions) 
    I_det = functions{i}(I,SE);
    fullDestinationFileName = fullfile(Folder_name0, strcat(names(i),'_og.jpeg'));
    imwrite(I_det, fullDestinationFileName)

end
dil = imread(fullfile(Folder_name0, strcat(names(1),'_og.jpeg')));
ero = imread(fullfile(Folder_name0, strcat(names(2),'_og.jpeg')));
for i = 1:length(names)
    if i == 1
        I_gr = dil - I;
    elseif i == 2
        I_gr = I - ero;
    else
        I_gr = dil - ero;
    end
    % Guardando detector en la imagen sin ruido
    fullDestinationFileName = fullfile(Folder_name0, strcat(names(i),'_gr_og.jpeg'));
    imwrite(I_gr, fullDestinationFileName)
end



for ss = 1:1:length(sigmm)
    %Leyendo imagen con ruido
    sstr=num2str(ss);
    gauss_name=strcat('Data\Ruido\Ruido_',sstr,'.jpg');
    Ierr=imread(gauss_name); %Im con Ruido Gaussiano

    Er = imerode(Ierr,SE); % imagen erosionada
    Di = imdilate(Ierr,SE); % imagen dilatada
    
    for grad = 1:length(names)

        Folder_name = strcat('Data\Morphologic_detectors\', names(grad));
        if ~exist(Folder_name, 'dir')
                mkdir(Folder_name);
        end

        filename = strcat(names(grad),'_',sstr,'.jpeg');
        fullDestinationFileName = fullfile(Folder_name, filename);

        if grad == 1
            Di = imdilate(Ierr,SE); % imagen dilatada
            %Gradiente por dilatacion
            G = Di-Ierr;

        elseif  grad == 2
            Er = imerode(Ierr,SE); % imagen erosionada
            %Gradiente por erosion
            G = Ierr-Er;

        else
            Er = imerode(Ierr,SE); % imagen erosionada
            Di = imdilate(Ierr,SE); % imagen dilatada
            %Gradiente morfologico
            G = Di-Er;
        end
        %Guardar el detector sobre imagen con ruido
        imwrite(G,fullDestinationFileName);
        % leer el detector sobre imagen con ruido
        G_sr = imread(strcat(Folder_name0, '\', names(i),'_gr_og.jpeg'));
        %guardando resultados
        Err_mse_Robust(grad,ss)=immse(uint8(G),uint8(G_sr));
    end
end

figure(1)
plot(sigmm, Err_mse_Robust(1,:),'-o', sigmm,  Err_mse_Robust(2,:),'-+', sigmm, Err_mse_Robust, '-*')
lgd=legend({'Gradiente por Erosión','Gradiente por Dilatación', 'Gradiente Morfológico'},'Location','northwest');
lgd.FontSize=11;
title('Error Cuadrático Medio Métodos MM. Robustez')
ylabel('ECM')
xlabel('\sigma^2')
set(gca,'ylim',[0 30000]);
saveas(figure(1),'Graphs\Err_MM_ECM_Robustez.jpg')



%Guardando Matrices de Error
writematrix(Err_mse_Robust','Matrices Error MM.xlsx','Sheet',1,'Range','A2:C22')



