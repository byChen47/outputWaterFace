
在OpenFOAM中直接采用sampling输出水面 

surface主要是用sampling输出水面，可以直接输出自由液面为0.5处的等值面的alpha.water、U、p
主要的用法，在constrolDict中添加: #include "surface"

#Ueqn
这个文件是在interFoam中添加源项，实现主动消波的效果
