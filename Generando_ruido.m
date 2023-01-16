% Generando el ruido:
% Generar las imagenes con ruido una vez para todo el analisis

clear

I=imread('Data\Original\18a.jpg');   %Imagen original
F=imread('Data\Original\18b.jpg');    %Imagen Objetivo

paso=0.005;
sigmm = 0:paso:0.1;    %Varianza gaussiana
                        
if ~exist('Data\Ruido', 'dir')
        mkdir('Data\Ruido');
end
for ss =1:1:length(sigmm)
    Ierr = imnoise(I,'gaussian',0,sigmm(ss));            %Ruido Gaussiano
    sstr=num2str(ss);
    gauss_name=strcat('Data\Ruido\Ruido_',sstr,'.jpg'); 
    imwrite(Ierr,gauss_name)                                     
end