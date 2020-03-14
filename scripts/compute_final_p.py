# -​*- coding: utf-8 -*​-
# @author: Laurent Hébert-Dufresne <lhebertd@uvm.edu>

# Packages
import numpy as np
from scipy.stats import nbinom as nbiom
import sys


def G1(x, r, p):
    return ((1 - p) / (1 - p*x))**r


def G0(x, r, p, p0):
    val = ((1 - p) / (1 - p*x))**(r-1)
    val = val * (1 - (1 - p*x)**(r-1)) / (1 - (1 - p)**(r-1))
    return p0 + ((1-p0) * val)


def solve_for_S(r, p, p0):
    u_old = 0        # Dummy value
    u_new = 0.31416  # Dummy value
    while not np.allclose(u_old, u_new, rtol=1e-03, atol=1e-05):
        u_old = u_new
        u_new = G1(u_old, r, p)
    return 1 - G0(u_new, r, p, p0)

def solve_for_z(X, Y):
	X = np.array(X)
	Y = np.array(Y)
	p = X/(Y+X)
	r = Y
	sigma2 = p * r / (1 - p)**2
	Z = solve_for_S(r, p, 0)
	return Z



