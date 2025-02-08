function [num] = filter_coefficient(filter_type,fs,fc_low,fc_up,f_stop1,f_stop2,f_pass1,f_pass2,n)

switch filter_type
    case 'lpf'
        M=(n-1)/2;
        wl = 2*pi*fc_low/fs;
        num = [];
        for k = 0:1:M
        pos = k+M+1;
        if k == 0
        num(pos) = wl/pi;
        else
        num(pos) = (sin(k*wl)/(k*pi));
        new_pos = pos-(2*k);
        num(new_pos) = num(pos);
        end
        end
        [hz,w]=freqz(num,[1],512,fs);
        
        
     case 'hpf'
        M=(n-1)/2;
        wh = 2*pi*fc_up/fs;
        num = [];
        for k = 0:1:M
        pos = k+M+1;
        if k == 0
        num(pos) = (pi-wh)/pi;
        else
        num(pos) = -(sin(k*wh)/(k*pi));
        new_pos = pos-(2*k);
        num(new_pos) = num(pos);
        end
        end
        [hz,w]=freqz(num,[1],512,fs);
      
      
     case 'bsf' 
         M=(n-1)/2;
         wl=2*pi*fc_low/fs;
         wh = 2*pi*fc_up/fs;
         num = []
         for k = 0:1:M
         pos = k+M+1;
         if k == 0
         num(pos) = pi-wh+wl/pi;
         else
         num(pos) = -(sin(k*wh)/(k*pi))+sin(k*wl)/(k*pi)
         new_pos = pos-(2*k)
         num(new_pos) = num(pos)
         end
         end
         [hz,w]=freqz(num,[1],512,fs);
    
    case 'bpf'
        M=(n-1)/2;
        fl=(f_stop1+f_pass1)/2;
        fh=(f_stop2+f_pass2)/2;
        wl=2*pi*fl/fs;
        wh = 2*pi*fh/fs;
        num = [];
        for k = 0:1:M
        pos = k+M+1;
        if k == 0
        num(pos) = (wh-wl)/pi;
        else
        num(pos) = (sin(k*wh)/(k*pi))-sin(k*wl)/(k*pi);
        new_pos = pos-(2*k);
        num(new_pos) = num(pos);
        end
        end
        [hz,w]=freqz(num,[1],512,fs);
     end
end

