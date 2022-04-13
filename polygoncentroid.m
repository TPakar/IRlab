function [xc,yc] = polygoncentroid(x,y)

%% This function gets the polygon centroids

xn = circshift(x,-1);
yn = circshift(y,-1);
A = x.*yn-xn.*y;
a = 3*sum(A);
xc = sum((x+xn).*A)/a;
yc = sum((y+yn).*A)/a;
end