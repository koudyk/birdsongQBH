clc
adir='F:\0.birdsongQBH\audio';
edir='F:\0.birdsongQBH\audio\examples';
qdir='F:\0.birdsongQBH\audio\queries';
addpath(genpath(adir))
load('b8_output_audioData_withAonly.mat')

t_play=3; % seconds - playing time

t_rec=1.5*t_play; % recording time

recObj=audiorecorder;
recAgain='y';
listenAgain='y';
for na=1:3%length(recDetA)
    clc,disp(['Loading audio ' num2str(na) '/' num2str(length(recDetA))])
    afile=[num2str(recDetA(na).id) '.wav'];
    [a,fs]=audioread(afile);
    

    while listenAgain=='y'; % WHILE THEY WANT TO HEAR THE AUDIO
        disp('Press a key when ready to hear audio')
        k=waitforbuttonpress;
        if k==1
            sound(a(1:t_play*fs),fs)
            pause(t_play)
        end
        listenAgain=input('Do you want listen to that again? [y/n]','s');
        
        if listenAgain=='n'
            while recAgain=='y'; % WHILE THEY WANT TO RECORD AGAIN
                disp('Press a key when ready to record imitation')
                k=waitforbuttonpress;
                pause(.5)
                if k==1
                    disp('Recording...')
                    recordblocking(recObj,t_rec)
                    disp('Done recording')          
                end
                recAgain=input('Do you want to record that again? (press y or n, then press Enter)','s');
                %if recAgain=='y' % IF THEY WANT TO RECORD AGAIN, DO THEY WANT TO LISTEN AGAIN?
                    listenAgain=input('Do you want to listen to the audio again? [y/n]','s');
                    if listenAgain=='y'
                        disp('Press a key when ready to hear audio')
                        k=waitforbuttonpress;
                        if k==1
                            sound(a(1:t_play*fs),fs)
                            pause(t_play)
                        end
                        listenAgain=input('Do you want listen to that again? [y/n]','s');
                    end
                %end
            end
            listenAgain='y';
        end
    end
        
        
        
        
end

    




%         for n=1:ceil(t_rec)
%             clc,disp(['recording... ' num2str(floor(t_rec)-n) '/' num2str(floor(t_rec)) ' more seconds'])
%             pause(1)

    
    
    






%         if listenAgain=='n'; % IF THEY DON'T WANT TO LISTEN AGAIN
%             disp('THEY DONT WANT TO LISTEN AGAIN')
% %           while recAgain=='y'; % WHILE THEY WANT TO RECORD AGAIN
% %                 disp('Press a key when ready to record imitation')
% %                 k=waitforbuttonpress;
% %                 pause(.5)
% %                 if k==1
% %                     disp('Recording...')
% %                     recordblocking(recObj,t_rec)
% %                     disp('Done recording')          
% %                 end
% %                 recAgain=input('Do you want to record that again? [y/n]','s');
% %                 if recAgain=='y' % IF THEY WANT TO RECORD AGAIN, DO THEY WANT TO LISTEN AGAIN?
% %                     listenAgain=input('Do you want to listen to the audio again? [y/n]','s');
% %                 else listenAgain='n';
% %                 end
% %           end
%         else,disp('THEY WANT TO LISTEN AGAIN')  
%         end
%         
%     end
%     
