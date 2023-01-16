
I=imread('Data\Original\18a.jpg');   %Imagen original
F=imread('Data\Original\18b.jpg');    %Imagen Objetivo

paso=0.005;
sigmm = 0:paso:0.1;                                      %Varianza gaussiana

%Detectores
names=["Prewitt" "Sobel"  "Roberts"  "Canny"  "log"  "Kirsch"];


%Matrices de Error
Err_mse_Robust=zeros(length(names),length(sigmm));

for index=1:length(names)
    %Detector en la imagen sin ruido
    if strcmp(names(index),'Canny')
        I_SR_bn = edge(I ,'Canny',[0.2, 0.4]);                           
        I_SR = uint8(I_SR_bn).*I;

    elseif strcmp(names(index),'log')
        I_SR_bn = edge(I,'log',[],2.5);                          
        I_SR = uint8(I_SR_bn).*I;

    elseif strcmp(names(index),'Kirsch')
            I_SR_bn=kirschedge(I);                             
            I_SR=uint8(I_SR_bn(2:end-1,2:end-1)).*I;
    else
        I_SR_bn = edge(I,names(index));                             
        I_SR = uint8(I_SR_bn).*I;
    end

    % Guardar detector sobre imagen original
    Folder_name0 = 'Data\Classic_detectors\Classic_det_og';
    if ~exist(Folder_name0, 'dir')
        mkdir(Folder_name0);
    end
    filename = strcat(names(index),'_og.jpeg');
    fullDestinationFileName = fullfile(Folder_name0, filename);
    imwrite(I_SR, fullDestinationFileName)

    for ss =1:1:length(sigmm)
        %Leyendo imagen con ruido
        sstr=num2str(ss);
        gauss_name=strcat('Data\Ruido\Ruido_',sstr,'.jpg');
        Ierr=imread(gauss_name);                            %Im con Ruido Gaussiano
        
        if strcmp(names(index),'Canny')
            EGerr=edge(Ierr,'Canny',[0.2, 0.4]);                      
            EGerr_gr=uint8(EGerr).*I;

        elseif strcmp(names(index),'log')
            EGerr=edge(Ierr,'log',[],2.5);                       
            EGerr_gr=uint8(EGerr).*I;

        elseif strcmp(names(index),'Kirsch')
            EGerr=kirschedge(I);                       
            EGerr_gr=uint8(EGerr(2:end-1,2:end-1)).*I;

        else

            EGerr=edge(Ierr,names(index));                      %Deteccion de Borde
            EGerr_gr=uint8(EGerr).*I;                           %Multiplicando por la Im original como mascara
        end

        %Guardar detector sobre imagen con ruido
        Folder_name = strcat('Data\Classic_detectors\', names(index));
        if ~exist(Folder_name, 'dir')
            mkdir(Folder_name);
        end
        
        filename = strcat(names(index),'_',sstr,'.jpeg');
        fullDestinationFileName = fullfile(Folder_name, filename);
        imwrite(EGerr_gr, fullDestinationFileName);

        %Error MeanSqE entre el detector sobre imagen original y con ruido 
        RRobusq = immse(EGerr_gr, I_SR);
        Err_mse_Robust(index,ss)=RRobusq;


    end
end

%Guardar los resultados
writematrix(Err_mse_Robust','Matrices Error Clasico.xlsx','Sheet',1,'Range','A2:F22')

figure(1)
plot(sigmm(1:11), Err_mse_Robust(1,1:11),'--mo', sigmm(1:11),  Err_mse_Robust(2,1:11), '--+c', sigmm(1:11), Err_mse_Robust(3,1:11), '--*g',sigmm(1:11),  Err_mse_Robust(4,1:11),'--pb', sigmm(1:11),Err_mse_Robust(5,1:11),'--sr')%, sigmm(1:11),Err_mse_Robust(6,1:11),'-->k')
lgd=legend({'Prewitt','Sobel', 'Roberts', 'Canny', 'LoG'},'Location','northwest');
lgd.FontSize = 11;
title('Error Cuadrático Medio Métodos Clásicos. Robustez')
ylabel('ECM')
xlabel('\sigma^2')
%set(gca,'ylim',[0 30000]);

if ~exist('Graphs', 'dir')
    mkdir('Graphs');
end
saveas(figure(1),'Graphs\Err_clasic_ECM.jpg')





function y=kirschedge(X)
    
    X=double(X);

    g1=[5,5,5; -3,0,-3; -3,-3,-3];
    g2=[5,5,-3; 5,0,-3; -3,-3,-3];
    g3=[5,-3,-3; 5,0,-3; 5,-3,-3];
    g4=[-3,-3,-3; 5,0,-3; 5,5,-3];
    g5=[-3,-3,-3; -3,0,-3; 5,5,5];
    g6=[-3,-3,-3; -3,0,5;-3,5,5];
    g7=[-3,-3,5; -3,0,5;-3,-3,5];
    g8=[-3,5,5; -3,0,5;-3,-3,-3];


    x1=conv2(g1,X);
    x2=conv2(g2,X);
    x3=conv2(g3,X);
    x4=conv2(g4,X);
    x5=conv2(g5,X);
    x6=conv2(g6,X);
    x7=conv2(g7,X);
    x8=conv2(g8,X);

   
    y1=max(x1,x2);
    y2=max(y1,x3);
    y3=max(y2,x4);
    y4=max(y3,x5);
    y5=max(y4,x6);
    y6=max(y5,x7);
    y7=max(y6,x8);
    y=y7;
    umbral=y>1000;
    y=y.*umbral;
end
