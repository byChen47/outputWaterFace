
在OpenFOAM中直接采用sampling输出水面 

surface主要是用sampling输出水面，可以直接输出自由液面为0.5处的等值面的alpha.water、U、p
主要的用法，在constrolDict中添加: #include "surface"
![image](https://github.com/byChen47/outputWaterFace/blob/main/surface.png)
![image](https://github.com/byChen47/outputWaterFace/blob/main/2024-04-08%20210017.png)
