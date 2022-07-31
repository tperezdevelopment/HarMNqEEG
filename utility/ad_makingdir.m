function [] = ad_makingdir(samedir)
    if ~exist(samedir, 'dir')
          mkdir (samedir)
    end    
   
end

