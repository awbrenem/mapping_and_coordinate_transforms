;Simple magnetic field focusing calculation due to convergence of
;magnetic field lines at higher latitudes. Uses simple dipole model.

;L = L-value
;alt = altitude above Earth's surface in km.
;size_eq = radius of flux tube at magnetic equator


;conservation of flux in narrowing flux tube
;Find ratio of B2/B1 = A1/A2
;A = r^2
;B2/B1 = (r1/r2)^2
;sep2 = sep1/(sqrt(B2/B1))


function magnetic_focusing_simple_dipole,L,alt,size_eq

  dip = dipole(L)
  Beq = dip.B[0]

  rval = 6370. + alt

  goo = where(dip.r le rval)
  Balt = dip.B[goo[0]]
  Brat = Balt/Beq
  size_alt = size_eq/(sqrt(Brat))


  vals = {B_ratio:Brat,size_at_alt:size_alt,Lval:L,alt_km:alt}
  return,vals

end
