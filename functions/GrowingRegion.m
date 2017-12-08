function MASK = GrowingRegion(MASK,RED, GREEN, BLUE,options)

for optical = 1:options.number_of_optic_sec 
    M = MASK{optical};
    red = RED{optical};
    green = GREEN{optical};
    blue = BLUE{optical};
    MASK{optical} = regionGrowingBacteria(M, red, green, blue,0);
end
