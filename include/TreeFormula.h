#ifndef TREE_FORMULA_H
#define TREE_FORMULA_H

typedef enum ElementTypes ElementTypes;
enum ElementTypes{
    BinOp,
    MonOp,
    Value,
    Variable
};

typedef enum BinOpTypes BinOpTypes;
enum BinOpTypes{
    Add,
    Sub,
    Mul,
    Div,
    Pow
};

enum MonOp{
    Abs,
    Neg
};



struct NodeFormula{

    void *data;
};

#endif