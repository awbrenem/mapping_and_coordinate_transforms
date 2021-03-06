;+
; Type: function.
; Purpose: Make arithmetic progression from x0 to x1, x1 - x0 = n*dx.
;   * mode = 'x0', a = x0, b = dx, c = n
;   * mode = 'x1', a = x1, b = dx, c = n.
;   * mode = 'dx', a = x0, b = x1, c = dx.
;   * mode = 'n',  a = x0, b = x1, c = n.
; Parameters:
;   a, in, double, req. Lower limit of the array. 
;   b, in, double, req. Upper limit of the array.
;   c, in, double/long, req. 
;   mode, in, string, opt. Use mode to specify various usages. 'dx' by default.
; Keywords: none.
; Return: double. Generated array.
; Notes: none.
; Dependence: none.
; History:
;   2012-09-19, Sheng Tian, create.
;   2012-10-29, Sheng Tian, add mode keyword.
;-

function smkarthm, a, b, c, mode
    if n_elements(mode) eq 0 then mode = 'dx'
    case mode of
        'x0' : return, a + dindgen(c) * b
        'x1' : return, a - reverse(dindgen(c)) * b
        'dx' : begin
            ns = floor(b-a)/c + 1
            return, a + dindgen(ns) * c
        end
        'n'  : begin
            dx = (b-a)/(double(c)-1)
            return, a + dindgen(c) * dx
        end
    endcase
end
