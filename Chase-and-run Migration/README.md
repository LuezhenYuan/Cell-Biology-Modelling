# Modelling the Neural Crest and Placode Cells Chase-and-run Migration

The chase-and-run behaviour contains two major steps: chemotaxis and contact inhibition of locomotion.


## Files in this folder
File | Usage
-----|-------
ncb2772-sv5-first75frames.tif | Data of chase-and-run migration.
Analsis_two_cell_types.m | Matlab script for the modelling and prediction.
Combine_Figure.png | Background and Model of chase-and-run migration.

## Background and Model

![Figure 1: Chase-and-run behaviour of NC and placode cells. (A) Main components in NC and placode cells' CIL. Wnt signalling and N-cadherin destablize focal adhesion and protrusion through the activation of RhoA and suquestering p120-catenin. Graph is modified from ref 6. (B) The kinetic energy of the center of mass shows no change before and after NC and placode collision. Data come from the supplimentary video 5 in ref 3. The mass of cell is replaced by the fluorescence intensity. (C) Model of NC cells Chemotaxis and NC and placode cells' CIL. Red refers to the group of placode cells. Green refers to the group of NC cells. Both of the cell groups have initial speed $Vg_0$ and $Vr_0$. The model assumes that when NC cells could sense the chemoattractant's gradient, it has an additive constant velocity $V_{chemotaxis}$ pointing to the placode cell group. When two cell groups contact, this model assume that the contact is a perfect elastic collision. (D) The larger graph shows the movement of the center of mass of each cell group. Data come from the same movie used in (A). The smaller graph shows the prediction of model in (C). Parameters (the initial velocities of two cell groups $Vg_0$ and $Vr_0$, the mass of each group, initial position of each group, velocity of chemotaxis $V_{chemotaxis}$) were calculated or estimated from the movie.](Combine_Figure.png)



## Data used
Supplimentary movie 5 from ref 1.

## Data preprocessing

1. Convert `.mov` movie file to ImageJ readable `.avi` file.

```
ffmpeg -i '..\..\..\lab\MB5101\Mid Term Test\ncb2772-sv5.mov' -qscale 0 -vcodec mjpeg -acodec copy '..\..\..\lab\MB5101\Mid Term Test\ncb2772-sv5.avi'
```

2. Convert `.avi` file to matlab readable `.tif` file.

## Data analysis
See `Analsis_two_cell_types.m`

## Modelling and prediction
See `Analsis_two_cell_types.m`


[1]: Theveneau, E., Steventon, B., Scarpa, E., Garcia, S., Trepat, X., Streit, A., and Mayor, R. Chase-and-run between adjacent cell populations promotes directional collective migration. Nature Cell Biology 15, 763–772 (2013).
