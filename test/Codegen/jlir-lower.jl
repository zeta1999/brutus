# RUN: julia --startup-file=no %s 2>&1 | FileCheck %s
import Brutus: emit

emit(identity, Bool, optimize=1, lower_to_llvm=1)
# CHECK: llvm.func @identity(%arg0: !llvm.i8) -> !llvm.i8
# CHECK:   %0 = llvm.mlir.undef : !llvm.void
# CHECK:   llvm.br ^bb1
# CHECK: ^bb1:
# CHECK:   llvm.return %arg0 : !llvm.i8
emit(identity, Nothing, optimize=1, lower_to_llvm=1)
# CHECK: llvm.func @identity()
# CHECK:   %0 = llvm.mlir.undef : !llvm.void
# CHECK:   %1 = llvm.mlir.undef : !llvm.void
# CHECK:   llvm.br ^bb1
# CHECK: ^bb1:
# CHECK:   llvm.return
emit(identity, Any, optimize=1, lower_to_llvm=1)
# CHECK: llvm.func @identity(%arg0: !llvm<"%jl_value_t*">) -> !llvm<"%jl_value_t*">
# CHECK:   %0 = llvm.mlir.undef : !llvm.void
# CHECK:   llvm.br ^bb1
# CHECK: ^bb1:
# CHECK:   llvm.return %arg0 : !llvm<"%jl_value_t*">

add(x, y) = x + y
emit(add, Int64, Int64, optimize=1, lower_to_llvm=1)
# CHECK: llvm.func @add(%arg0: !llvm.i64, %arg1: !llvm.i64) -> !llvm.i64
# CHECK:   %0 = llvm.mlir.undef : !llvm.void
# CHECK:   llvm.br ^bb1
# CHECK: ^bb1:
# CHECK:   %1 = llvm.add %arg0, %arg1 : !llvm.i64
# CHECK:   llvm.return %1 : !llvm.i64
emit(add, Float64, Float64, optimize=1, lower_to_llvm=1)
# CHECK: llvm.func @add(%arg0: !llvm.double, %arg1: !llvm.double) -> !llvm.double
# CHECK:   %0 = llvm.mlir.undef : !llvm.void
# CHECK:   llvm.br ^bb1
# CHECK: ^bb1:
# CHECK:   %1 = llvm.fadd %arg0, %arg1 : !llvm.double
# CHECK:   llvm.return %1 : !llvm.double

sle_int(x, y) = Base.sle_int(x, y)
emit(sle_int, Int64, Int64, optimize=1, lower_to_llvm=1)
# CHECK: llvm.func @sle_int(%arg0: !llvm.i64, %arg1: !llvm.i64) -> !llvm.i8
# CHECK:   %0 = llvm.mlir.undef : !llvm.void
# CHECK:   llvm.br ^bb1
# CHECK: ^bb1:
# CHECK:   %1 = llvm.icmp "sle" %arg0, %arg1 : !llvm.i64
# CHECK:   %2 = llvm.zext %1 : !llvm.i1 to !llvm.i8
# CHECK:   llvm.return %2 : !llvm.i8

ne(x, y) = x != y
emit(ne, Float64, Float64, optimize=1, lower_to_llvm=1)
# CHECK: llvm.func @ne(%arg0: !llvm.double, %arg1: !llvm.double) -> !llvm.i8
# CHECK:   %0 = llvm.mlir.undef : !llvm.void
# CHECK:   llvm.br ^bb1
# CHECK: ^bb1:
# CHECK:   %1 = llvm.fcmp "une" %arg0, %arg1 : !llvm.double
# CHECK:   %2 = llvm.zext %1 : !llvm.i1 to !llvm.i8
# CHECK:   llvm.return %2 : !llvm.i8

symbol() = :testing
emit(symbol, optimize=1, lower_to_llvm=1)
# CHECK: llvm.func @symbol() -> !llvm<"%jl_value_t*">
# CHECK:   %0 = llvm.mlir.undef : !llvm.void
# CHECK:   llvm.br ^bb1
# CHECK: ^bb1:
# CHECK:   %1 = llvm.mlir.constant({{[0-9]+}} : i64) : !llvm.i64
# CHECK:   %2 = llvm.inttoptr %1 : !llvm.i64 to !llvm<"%jl_value_t*">
# CHECK:   llvm.return %2 : !llvm<"%jl_value_t*">
