%% Master registration for multi slide and or multi directory cyclic images%%
% template for preprocess.py modification
% Author: engje
% Date: 2019-11-11
%
% Intructions: 
%   Use cmif.preprocess.large_registration_matlab() function to edit and run this template
%
% Input : original tiffs or big tiffs (ending in ORG.tif)
%   Note: cannot have rounds in separate folders
%   Can have different slides/scenes in same folder or separate folders
%   Filename convention 'Rx_Bi.o.mark.ers_Slidename-Section(-Scene)_xxx_xx_x_cx_ORG.tif'
%       Where c1 is DAPI and x can be variable (i.e. from axioscan)
%
% Output: registered tiffs in 'Registered-slide(-scene)' folders
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% I. Parameters: modify each time
N_smpl = i_N_smpl; %number of features to detect in image (default = 10000)
N_colors = i_N_colors; %number of colors in R1 (default = 5)
ls_order = {RoundOrderString}; %list of names and order of rounds
s_rootdir = 'PathtoImages' %location of raw images in folder
s_ref_id = 'RefDapiUniqueID'; %shared unique identifier of reference dapi
s_subdirname = 'PathtoRegisteredImages' %location of folder where registered images will reside

%scene definitions [x y width height]
%1%1%a_crop_1 = [a_crop_1];
%2%2%a_crop_2 = [a_crop_2];
%3%3%a_crop_3 = [a_crop_3];
%4%4%a_crop_4 = [a_crop_4];
%5%5%a_crop_5 = [a_crop_5];

%6%6%a_crop_6 = [a_crop_6];
%7%7%a_crop_7 = [a_crop_7];
%8%8%a_crop_8 = [a_crop_8];
%9%9%a_crop_9 = [a_crop_9];
%10%10%a_crop_10 = [a_crop_10];

%% III. find slides in each directory/subdirectory, display
%% III. find slides display

N_slide_found = 0;
ls_fname_ref = {};

cd(s_rootdir)
%look for reference dapi image(s) in subdirectory
fname_ref = dir(sprintf('%s',s_ref_id));
    
%make list of all reference dapi
ls_fname_ref = [ls_fname_ref {fname_ref.name}];
        
%get slide name and scene of reference dapi
for i = 1:length(fname_ref)
    fname_img = fname_ref(i).name;
    u = strfind(fname_img,'_');
    s = strfind(fname_img, '-Scene-');
    first = sprintf('%s',fname_img(u(2)+1:u(3)-1));
    last = sprintf('%s',fname_img(s:(u(end-1)-1)));
    fname_slide_scene = sprintf('%s%s',first,last);
           
    %count number of slides found
    N_slide_found = N_slide_found + 1;   
end

fprintf('DAPI slides found:\n')

for i = 1:length(ls_fname_ref)
    fprintf('%s\n',cell2mat(ls_fname_ref(i)))
end

fprintf('Total DAPI slides found: %d \n',N_slide_found)

cd(s_rootdir)

fprintf('Processing %s\n',s_rootdir);
fprintf('Processing %s\n',cell2mat(ls_fname_ref(1)));
    
%% V. Registration

% registration loop (a single folder, different from versions before 2019-11-11) 
for i = 1:length(ls_fname_ref)
            
            d = dir();
            d = {d.name};

       if sum(contains(d,ls_fname_ref(i))) == 1

            fprintf(' %s\n',cell2mat(ls_fname_ref(i)));
                      
            %read reference DAPI
            DAPI_R1=imread(cell2mat(ls_fname_ref(i)));%read DAPI R1
            I_ref=imadjust(DAPI_R1);%adjust DAPI R1
            ptsRef=detectSURFFeatures(I_ref);%detect features of DAPI R1
            ptsRef=ptsRef.selectStrongest(N_smpl);%select N_smpl (e.g. 10000) strongest feature
            [featuresRef, validPtsRef] = extractFeatures( I_ref, ptsRef);%get features and locations of DAPI R1
            outputView=imref2d(size(DAPI_R1)); %get reference coordinate system
            
            %get slide/scene name
            fname_slide = cell2mat(ls_fname_ref(i));
            u = strfind(fname_slide,'_');
            fname_slide = fname_slide(u(2)+1:u(3)-1);
    
            %get all file names with slide name inside (ordered by round)
            slide = string();
            for j=1:length(ls_order)
                fnameall = dir(sprintf('%s_*ORG.tif',ls_order{j}));
                for k = 1:length(fnameall)
                    TF = contains(fnameall(k).name,fname_slide);
                        if TF == 1
                            slide = [slide fnameall(k).name];
                        end  
                end
            end
            slide(1) = [];

        %Round 1 write files
    
            subdirname = sprintf('%s%s',s_subdirname,fname_slide); %write images to folder with slide name

            for l=1:N_colors %for each of R1 files
                long=char(slide(l)); %save name
                u = strfind(long,'_');
                first = sprintf('%s',long(1:u(3)-1));
                last = sprintf('%s',long(u(end-1):end));
                %write R1 files, don't need to register, just rename
                I = imread(slide{l});
                
                %Scene 1-5
                %1%1%imwrite((imcrop(I,a_crop_1)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,1,first,1,last));
                %2%2%imwrite((imcrop(I,a_crop_2)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,2,first,2,last));
                %3%3%imwrite((imcrop(I,a_crop_3)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,3,first,3,last));
                %4%4%imwrite((imcrop(I,a_crop_4)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,4,first,4,last));
                %5%5%imwrite((imcrop(I,a_crop_5)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,5,first,5,last));

                %Scene 6-10
                %6%6%imwrite((imcrop(I,a_crop_6)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,6,first,6,last));
                %7%7%imwrite((imcrop(I,a_crop_7)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,7,first,7,last));
                %8%8%imwrite((imcrop(I,a_crop_8)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,8,first,8,last));
                %9%9%imwrite((imcrop(I,a_crop_9)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,9,first,9,last));
                %10%10%imwrite((imcrop(I,a_crop_10)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,10,first,10,last));
%               
                %clean up
                clear I
            end

        % Round 2+ DAPI registration & write files
        N_rounds = contains(slide, 'c1_ORG.tif');
        DAPI_slide = slide(N_rounds);

        for ii= 2: length(DAPI_slide)%for second round DAPI and above (those that need to be registered)

            DAPI=imread(DAPI_slide{ii});%read DAPI image
            I_obj=imadjust(DAPI);%adjust DAPI image
            ptsObj=detectSURFFeatures(I_obj);
            ptsObj=ptsObj.selectStrongest(N_smpl);
            [featuresObj, validPtsObj] = extractFeatures( I_obj, ptsObj);
            indxPairs = matchFeatures(featuresRef, featuresObj);
            matchedRef = validPtsRef(indxPairs(:,1));
            matchedObj = validPtsObj(indxPairs(:,2));

            %actual registration 
            [tform, inlierDistorted, inlierOriginal,status] = estimateGeometricTransform(...
            matchedObj, matchedRef,  'similarity', 'MaxNumTrials',20000, 'Confidence',95, 'MaxDistance', 10);
            [registered_DAPI,registered_DAPI_ref] = imwarp(DAPI, tform, 'OutputView', outputView);

            %write registered c1-c5
            round = contains(slide, sprintf('%s_',cell2mat(ls_order(ii)))); %all names in R_order(i)
            fname_R = slide(round);
            if sum(round) == 0
                continue
            else 
                for jj=1:length(fname_R)
                    long=fname_R{jj};
                    u = strfind(long,'_');
                    first = sprintf('%s',long(1:u(3)-1));
                    last = sprintf('%s',long(u(end-1):end));
                    [registered_marker,registered_marker_ref]=imwarp(imread(fname_R{jj}),...
                    tform,'OutputView',outputView);%transform all rounds 2 and higher
                    I = registered_marker;%write images
                
                    %clean up
                    clear registered_marker;
                
                    %Scene 1-5
                    %1%1%imwrite((imcrop(I,a_crop_1)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,1,first,1,last));
                    %2%2%imwrite((imcrop(I,a_crop_2)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,2,first,2,last));
                    %3%3%imwrite((imcrop(I,a_crop_3)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,3,first,3,last));
                    %4%4%imwrite((imcrop(I,a_crop_4)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,4,first,4,last));
                    %5%5%imwrite((imcrop(I,a_crop_5)),sprintf('%s-Scene-%03d/Registered-%s-Scene-%03d%s',subdirname,5,first,5,last));

                    %Scene 6-10
                    %6%6%imwrite((imcrop(I,a_crop_6)),sprintf('%sRegistered-%s-Scene-%03d%s',subdirname,6,first,6,last));
                    %7%7%imwrite((imcrop(I,a_crop_7)),sprintf('%sRegistered-%s-Scene-%03d%s',subdirname,7,first,7,last));
                    %8%8%imwrite((imcrop(I,a_crop_8)),sprintf('%sRegistered-%s-Scene-%03d%s',subdirname,8,first,8,last));
                    %9%9%imwrite((imcrop(I,a_crop_9)),sprintf('%sRegistered-%s-Scene-%03d%s',subdirname,9,first,9,last));
                    %10%10%imwrite((imcrop(I,a_crop_10)),sprintf('%sRegistered-%s-Scene-%03d%s',subdirname,10,first,10,last));
                end
            end
        end
       else
           break
       end
end

            
            
        