from opcodes import AND, SDIV, SGT, SLT, MUL, GT, DIV
from rule import Rule
from util import BVSignedMax, BVSignedMin, BVSignedUpCast
from z3 import BVMulNoOverflow, BVMulNoUnderflow, BitVec, Not, Or

"""
Overflow checked signed integer multiplication.
"""

# Approximation with 16-bit base types.
n_bits = 16
type_bits = 4

while type_bits <= n_bits:

	rule = Rule()

	# Input vars
	X_short = BitVec('X', type_bits)
	Y_short = BitVec('Y', type_bits)

	# Z3's overflow and underflow conditions
	actual_overflow = Not(BVMulNoOverflow(X_short, Y_short, True))
	actual_underflow = Not(BVMulNoUnderflow(X_short, Y_short))

	# cast to full n_bits values
	X = BVSignedUpCast(X_short, n_bits)
	Y = BVSignedUpCast(Y_short, n_bits)
	product = MUL(X, Y)

	# Constants
	maxValue = BVSignedMax(type_bits, n_bits)
	minValue = BVSignedMin(type_bits, n_bits)

	# Overflow and underflow checks in YulUtilFunction::overflowCheckedIntMulFunction
	if type_bits > n_bits / 2:
		overflow_check_1 = AND(AND(SGT(X, 0), SGT(Y, 0)), GT(X, DIV(maxValue, Y)))
		underflow_check_1 = AND(AND(SGT(X, 0), SLT(Y, 0)), SLT(Y, SDIV(minValue, X)))
		underflow_check_2 = AND(AND(SLT(X, 0), SGT(Y, 0)), SLT(X, SDIV(minValue, Y)))
		overflow_check_2 = AND(AND(SLT(X, 0), SLT(Y, 0)), SLT(X, SDIV(maxValue, Y)))
	else:
		overflow_check_1 = SGT(product, maxValue)
		underflow_check_1 = SLT(product, minValue)
		underflow_check_2 = underflow_check_1
		overflow_check_2 = overflow_check_1

	rule.check(actual_overflow, Or(overflow_check_1 != 0, overflow_check_2 != 0))
	rule.check(actual_underflow, Or(underflow_check_1 != 0, underflow_check_2 != 0))

	type_bits += 4
