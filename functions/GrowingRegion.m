function MASK = GrowingRegion(MASK,RED, GREEN, BLUE,options)

for optical = 1:options.number_of_optic_sec 
    fprintf('Region growing for section %i\n',optical);
    M = MASK{optical};
    red = RED{optical};
    green = GREEN{optical};
    blue = BLUE{optical};
    MASK{optical} = regionGrowingBacteria(M, red, green, blue,options);
end
