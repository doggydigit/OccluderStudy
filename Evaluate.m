% clear all
% close all
% load Occluded_C101_p227.mat

labels = {{'BRAIN'}
    {'plane', 'warplane', 'airliner'}
    {'BONSAI'}
    {'BUDDHA'}
    {'monarch', 'ringlet', 'lycaenid'}
    {'CHANDELIER'}
    {'rock crab', 'Dungeness crab', 'king crab', 'fiddler crab'}
    {'American lobster', 'crayfish', 'spiny lobster'}
    {'dalmatian'}
    {'vase', 'whiskey jug', 'pitcher', 'water jug', 'teapot'} % 10
    {'FACE'}
    {'grand piano'}
    {'loggerhead', 'leatherback turtle', 'terrapin'}
    {'HELICOPTER'}
    {'black stork', 'spoonbill', 'hornbill', 'goose', 'white stork', 'vulture', 'dowitcher', 'redshank', 'crane', 'little blue heron', 'magpie', 'coucal', 'limpkin', 'sulphur-crested cockatoo', 'flamingo', 'American egret', 'house finch', 'macaw'}
    {'wallaby'}
    {'catamaran', 'yawl', 'schooner', 'trimaran'} % 17
    {'notebook', 'laptop', 'screen', 'space bar', 'hand-held computer', 'desktop computer', 'iPod'}
    {'cheetah', 'leopard', 'jaguar'}
    {'llama'} % 20
    {'MENORAH'}
    {'tricycle', 'moped', 'bicycle-built-for-two', 'mountain bike', 'motor scooter'}
    {'revolver', 'rifle', 'assault rifle'}
    {'starfish'} % 24
    {'SUNFLOWER'}
    {'trilobite', 'chiton'}
    {'umbrella'} % 27
    {'analog clock', 'stopwatch', 'digital watch', 'wall clock', 'digital clock'}
    };

goodclasses = [0,1,0,0,1,0,1,1,1,1,0,1,1,0,1,1,1,1,1,1,0,1,1,1,0,1,1,1];

nrclasses = length(classes);
accuracy = zeros(nrclasses, nr_radi);
totalaccu = zeros(nr_radi, 1);
for r=1:nr_radi
    for c=1:nrclasses
        if goodclasses(c)
            for i=1:length(occluded_images{r}{c})
               l = classify(net,occluded_images{r}{c}{i});
               if any(strcmp(labels{c},char(l(1))))
                   accuracy(c,r) = accuracy(c,r) + 1;
               end
            end
            accuracy(c,r) = accuracy(c,r)/length(occluded_images{r}{c});
            totalaccu(r) = totalaccu(r) + accuracy(c,r);
        end
    end
end
totalaccu = totalaccu/20;

save('alexnet_accuracy', 'accuracy', 'totalaccu')