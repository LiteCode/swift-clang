
@interface MyClass

// all-methods-begin: +1:1
- (void)method;

+ (void)classMethod;

- (void)implementedMethod;

- (void)method:(int)x with:(int)y;
// all-methods-end: +0:1

@end

#ifndef NO_IMPL
@implementation MyClass

- (void)someOtherMethod { }

@end
// CHECK1: "{{.*}}implement-declared-methods.m" "- (void)method { \n  <#code#>;\n}\n\n+ (void)classMethod { \n  <#code#>;\n}\n\n- (void)implementedMethod { \n  <#code#>;\n}\n\n- (void)method:(int)x with:(int)y { \n  <#code#>;\n}\n\n" [[@LINE-1]]:1 -> [[@LINE-1]]:1
// CHECK2: "{{.*}}implement-declared-methods.m" "- (void)method { \n  <#code#>;\n}\n\n- (void)implementedMethod { \n  <#code#>;\n}\n\n" [[@LINE-2]]:1
#endif
// RUN: clang-refactor-test perform -action implement-declared-methods -selected=all-methods -continuation-file=%s -query-results=query-all-impl %s | FileCheck --check-prefix=CHECK1 %s
// RUN: clang-refactor-test perform -action implement-declared-methods -selected=all-methods -continuation-file=%s -query-results=query-mix-impl %s | FileCheck --check-prefix=CHECK2 %s

// query-all-impl: [ { name: ast.producer.query, filenameResult: "%s" } , { name: decl.query , predicateResults: [{name: decl.isDefined, intValues: [0, 0, 0, 0] }] }]
// query-mix-impl: [ { name: ast.producer.query, filenameResult: "%s" } , { name: decl.query , predicateResults: [{name: decl.isDefined, intValues: [0, 1, 0, 1] }] }]

// Empty continuation TU or TU without @implementation should produce an error:
// RUN: not clang-refactor-test perform -action implement-declared-methods -selected=all-methods -continuation-file=%S/Inputs/empty.cpp -query-results=query-all-impl %s 2>&1 | FileCheck --check-prefix=CHECK-EMPTY-ERR %s
// RUN: not clang-refactor-test perform -action implement-declared-methods -selected=all-methods -continuation-file=%s -query-results=query-all-impl %s -DNO_IMPL 2>&1 | FileCheck --check-prefix=CHECK-EMPTY-ERR %s
// CHECK-EMPTY-ERR: failed to perform the refactoring continuation (the target @interface is not implemented in the continuation AST unit)!

// RUN: clang-refactor-test perform -action implement-declared-methods -selected=all-methods -continuation-file=%S/Inputs/objcClass.m -query-results=query-all-impl %s -DNO_IMPL | FileCheck --check-prefix=CHECK1 %S/Inputs/objcClass.m
// RUN: clang-refactor-test perform -action implement-declared-methods -selected=all-methods -continuation-file=%S/Inputs/objcClass.m -query-results=query-mix-impl %s -DNO_IMPL -DMIX_IMPL | FileCheck --check-prefix=CHECK2 %S/Inputs/objcClass.m

@interface MyClass (Category)

// all-category-methods-begin: +1:1
- (void)categoryMethod;
+ (MyClass *)classCategoryMethod;
// all-category-methods-end: +0:1

@end

@implementation MyClass (Category)

- (void)anotherMethod {
}

@end
// CHECK3: "{{.*}}implement-declared-methods.m" "- (void)categoryMethod { \n  <#code#>;\n}\n\n+ (MyClass *)classCategoryMethod { \n  <#code#>;\n}\n\n" [[@LINE-1]]:1
// RUN: clang-refactor-test perform -action implement-declared-methods -selected=all-category-methods -continuation-file=%s -query-results=query-all-impl %s | FileCheck --check-prefix=CHECK3 %s