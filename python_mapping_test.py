#Test of Sheng's geopack for Python 
from geopack import geopack
import matplotlib as plt
import math
import datetime
from dateutil import parser
import numpy as np 

# From date and time
t1 = datetime.datetime(2017,11,28,11,42,0)
tref = datetime.datetime(1970,1,1)
ut = (t1-tref).total_seconds()
#print(ut)
#978404645.0   #Correct. Tested against IDL
ps = geopack.recalc(ut)


#RBSPa test (2017-11-28 at 11 UT) from SSCWeb 
       Time                   GEO (RE)                         GSE (RE)                         GSM (RE)                          SM (RE)            
yy/mm/dd hh:mm:ss      X          Y          Z          X          Y          Z          X          Y          Z          X          Y          Z    
17/11/28 11:00:00       4.16      -2.74       0.86       2.95      -3.85       1.44       2.95      -3.12       2.67       3.69      -3.12       1.49

17/11/28 11:42:00       4.44      -3.12       0.94       3.71      -3.60       1.88 09:03:18       3.71      -2.77       2.97       4.46      -2.77       1.64 09:52:35    6.0



xgse = 3.71*6370. 
ygse = -3.60*6370.
zgse = 1.88*6370.


xgsm,ygsm,zgsm = geopack.gsmgse(xgse,ygse,zgse,-1)


>>> xgsm/6370.,ygsm/6370.,zgsm/6370.
(2.95, -3.1273230574420965, 2.6675738967067084)
SSCWeb: 2.95      -3.12       2.67 

xsm,ysm,zsm = geopack.smgsm(xgsm,ygsm,zgsm,-1)
>>> xsm/6370.,ysm/6370.,zsm/6370.
(3.689314306035872, -3.1273230574420965, 1.4857356580731518)
SSCWeb: 3.69      -3.12       1.49




xmag,ymag,zmag = geopack.magsm(xsm,ysm,zsm,-1)
>>> xmag/6370.,ymag/6370.,zmag/6370.
(3.662930948953459, 3.1581840379447224, 1.4857356580731518)


xgeo,ygeo,zgeo = geopack.geomag(xmag,ymag,zmag,-1)
>>> xgeo/6370.,ygeo/6370.,zgeo/6370.
(4.165002940604838, -2.7410602003493305, 0.8590340405443283)
SSCWeb: 4.16      -2.74       0.86



#r, theta(rad), phi(rad)
sph_geo = geopack.sphcar(xgeo,ygeo,zgeo,-1)
#(32229.05261313151, 1.4001836599493598, 5.7011249217417355)
r = sph_geo[0]/6370.
lat_from_eq = 90. - math.degrees(sph_geo[1])
long_east = math.degrees(sph_geo[2])
long_west = 180. - long_east


#Test to see if we're within the SAA (see Arlo Johnson 2021 paper. He uses a definition of 
#a Latitude between 0 and 80, and Longitude between -90 and 60
long_test = long_west > -90. and long_east < 60.
lat_test = lat_from_eq < 80. and lat_from_eq > 0.





#Firebird location test 
FU3 at 11:42  geo = -0.33       0.66      -0.78      
FU3 at 11:44  geo = -0.25       0.58      -0.87
FU4 at 11:44  geo =  0.33      -0.17      -1.02

xgeo,ygeo,zgeo = 6370.*0.33,6370.*-0.17,6370.*-1.02
sph_geo = geopack.sphcar(xgeo,ygeo,zgeo,-1)
r = sph_geo[0]/6370.
lat_from_eq = 90. - math.degrees(sph_geo[1])
long_east = math.degrees(sph_geo[2])
long_west = 180. - long_east

long_test = long_west > -90. and long_east < 60.
lat_test = lat_from_eq < 80. and lat_from_eq > 0.








#-----------------------------------------------------------
#Test mapping of SAA back to L, MLT during certain times. 
t0 = datetime.datetime(2017,11,28,11,00)
t1 = datetime.datetime(2017,11,28,12,00)



#Geo coordinates of the edges of the SAA
sph_geo1 = geopack.sphcar(6370.,math.radians(90.),math.radians(60.),1)
sph_geo2 = geopack.sphcar(6370.,math.radians(90.),math.radians(-90.),1)


for i in range(2):

ut = (t0-tref).total_seconds()
ps = geopack.recalc(ut)


xmag,ymag,zmag = geopack.geomag(sph_geo1[0],sph_geo1[1],sph_geo1[2],1)
xsm,ysm,zsm = geopack.magsm(xmag,ymag,zmag,1)
xgsm,ygsm,zgsm = geopack.smgsm(xsm,ysm,zsm,1)
#xgse,ygse,zgse = geopack.gsmgse(xgsm,ygsm,zgsm,1)


angle_tmp = math.degrees(math.atan2(ygsm,xgsm))
if angle_tmp < 0: 
    angle_tmp = 360. - abs(angle_tmp)


MLT = angle_tmp * (12/180.) + 12.

if MLT >= 24.:
    MLT = MLT - 24.



print(MLT)











x = load_firebird_microburst_list('3')
tdbl = time_double(x.time)
t0 = time_double('2017-11-28/00:00')
t1 = time_double('2017-11-29/00:00')

goo = where((tdbl ge t0) and (tdbl le t1))

print,x.time[goo]


