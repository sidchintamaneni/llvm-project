; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes='default<O2>' -S < %s | FileCheck %s

define void @copy(ptr noalias %to, ptr noalias %from) {
; CHECK-LABEL: @copy(
; CHECK-NEXT:    [[X:%.*]] = load i32, ptr [[FROM:%.*]], align 4
; CHECK-NEXT:    store i32 [[X]], ptr [[TO:%.*]], align 4
; CHECK-NEXT:    ret void
;
  %x = load i32, ptr %from
  store i32 %x, ptr %to
  ret void
}

; Consider that %addr1 = %addr2 + 1, in which case %addr2i and %addr1i are
; noalias within one iteration, but may alias across iterations.
define void @pr39282(ptr %addr1, ptr %addr2) {
; CHECK-LABEL: @pr39282(
; CHECK-NEXT:  start:
; CHECK-NEXT:    tail call void @llvm.experimental.noalias.scope.decl(metadata [[META0:![0-9]+]])
; CHECK-NEXT:    tail call void @llvm.experimental.noalias.scope.decl(metadata [[META3:![0-9]+]])
; CHECK-NEXT:    [[X_I:%.*]] = load i32, ptr [[ADDR1:%.*]], align 4, !alias.scope !3, !noalias !0
; CHECK-NEXT:    store i32 [[X_I]], ptr [[ADDR2:%.*]], align 4, !alias.scope !0, !noalias !3
; CHECK-NEXT:    [[ADDR1I_1:%.*]] = getelementptr inbounds i8, ptr [[ADDR1]], i64 4
; CHECK-NEXT:    [[ADDR2I_1:%.*]] = getelementptr inbounds i8, ptr [[ADDR2]], i64 4
; CHECK-NEXT:    tail call void @llvm.experimental.noalias.scope.decl(metadata [[META5:![0-9]+]])
; CHECK-NEXT:    tail call void @llvm.experimental.noalias.scope.decl(metadata [[META7:![0-9]+]])
; CHECK-NEXT:    [[X_I_1:%.*]] = load i32, ptr [[ADDR1I_1]], align 4, !alias.scope !7, !noalias !5
; CHECK-NEXT:    store i32 [[X_I_1]], ptr [[ADDR2I_1]], align 4, !alias.scope !5, !noalias !7
; CHECK-NEXT:    tail call void @llvm.experimental.noalias.scope.decl(metadata [[META9:![0-9]+]])
; CHECK-NEXT:    tail call void @llvm.experimental.noalias.scope.decl(metadata [[META11:![0-9]+]])
; CHECK-NEXT:    [[X_I_2:%.*]] = load i32, ptr [[ADDR1]], align 4, !alias.scope !11, !noalias !9
; CHECK-NEXT:    store i32 [[X_I_2]], ptr [[ADDR2]], align 4, !alias.scope !9, !noalias !11
; CHECK-NEXT:    tail call void @llvm.experimental.noalias.scope.decl(metadata [[META13:![0-9]+]])
; CHECK-NEXT:    tail call void @llvm.experimental.noalias.scope.decl(metadata [[META15:![0-9]+]])
; CHECK-NEXT:    [[X_I_3:%.*]] = load i32, ptr [[ADDR1I_1]], align 4, !alias.scope !15, !noalias !13
; CHECK-NEXT:    store i32 [[X_I_3]], ptr [[ADDR2I_1]], align 4, !alias.scope !13, !noalias !15
; CHECK-NEXT:    ret void
;
start:
  br label %body

body:
  %i = phi i32 [ 0, %start ], [ %i.next, %body ]
  %j = and i32 %i, 1
  %addr1i = getelementptr inbounds i32, ptr %addr1, i32 %j
  %addr2i = getelementptr inbounds i32, ptr %addr2, i32 %j
  call void @copy(ptr %addr2i, ptr %addr1i)
  %i.next = add i32 %i, 1
  %cmp = icmp slt i32 %i.next, 4
  br i1 %cmp, label %body, label %end

end:
  ret void
}
