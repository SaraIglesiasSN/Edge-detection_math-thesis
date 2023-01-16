clear
I=imread('Data\Original\18a.jpg');   %Imagen original
F=imread('Data\Original\18b.jpg');    %Imagen Objetivo

paso=0.005;
sigmm = 0:paso:0.05;                                      %Varianza gaussiana


%Orden de t- normas: Estandar, Acotada, Algebraica, Dubois&Prade, Hamacher.
%Gr_Dil, Gr_Ero, Gr_MM

normas=["Estándar", "Acotada","Algebraica", "Dubois and Prade", "Hamacher"];
normas2=["est","acot","alg", "DP", "Ham"];
grnames=["Dil","Ero","MM"];

%Matrices de Error;
Err_mse_Robust=zeros(15,length(sigmm));

%Las imagenes ya estan generadas

for gr=1:3
    for index=1:length(normas)
        %Detector sobre imagen sin ruido
        sr_name=strcat('Data\FuzzyMorphologic_detectors\',normas(index),'\Gr_',grnames(gr),'_fzz\Gr',grnames(gr),'_t_',normas2(index),'_1.jpg');
        Im_sr=imread(sr_name);
    
        for ss =1:1:length(sigmm)  
            %Detector sobre imagen con ruido
            sstr=num2str(ss);
            Gr_err_name=strcat('Data\FuzzyMorphologic_detectors\',normas(index),'\Gr_',grnames(gr),'_fzz\Gr',grnames(gr),'_t_',normas2(index),'_',sstr,'.jpg');
            I_err=imread(Gr_err_name);

        Err_mse_Robust(3*(index-1)+gr,ss)=immse(uint8(I_err(:,:,1)),uint8(Im_sr(:,:,1)));

        end
    end
end


%POR T-NORMA

for fig=1:5
    figure(fig)
    plot(sigmm, Err_mse_Robust(3*(fig-1)+1,:),'-o', sigmm,  Err_mse_Robust(3*(fig-1)+2,:),'-+', sigmm, Err_mse_Robust(3*(fig-1)+3,:), '-*')
    lgd=legend({'Gradiente Difuso por Dilatación','Gradiente Difuso por Erosión', 'Gradiente Difuso Morfológico'},'Location','northwest');
    lgd.FontSize = 12;
    tt=title(strcat('ECM t-norma: ', normas(fig)));
    tt.FontSize=13;
    ylabel('ECM')
    xlabel('\sigma')
    set(gca,'ylim',[0 14000]);
    name=strcat('Graphs\Err_Fzz_ECM_Robustez_',normas(fig),'.jpg');
    saveas(figure(fig),name);
end
%POR GRADIENTE
GRSS=["Gradiente Difuso por Dilatación", "Gradiente Difuso por Erosión","Gradiente Difuso Morfológico"];

for fig=1:3
    figure(fig)
    plot(sigmm, Err_mse_Robust(3*(1-1)+fig,:),sigmm, Err_mse_Robust(3*(2-1)+fig,:),sigmm, Err_mse_Robust(3*(3-1)+fig,:),sigmm, Err_mse_Robust(3*(4-1)+fig,:),sigmm, Err_mse_Robust(3*(5-1)+fig,:))
    legend({'t-norma Estándar', 't-norma Acotada','t-norma Algebraica', 't-norma Dubois and Prade', 't-norma Hamacher'},'Location','northwest')
    title(strcat('ECM según t-norma (Robustez) de:', GRSS(fig)))
    ylabel('ECM')
    xlabel('\sigma')
    set(gca,'ylim',[0 30000]);
    name=strcat('Graphs\Err_Fzz_ECM_Robustez_',GRSS(fig),'.jpg');
    saveas(figure(fig),name);
end

%Guardando Matrices de Error
writematrix(Err_mse_Robust','Matrices Error Fzz.xlsx','Sheet',2,'Range','A3:O23')
