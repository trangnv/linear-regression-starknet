namespace DataTypes {
    struct PolynomialRegression {
        number_features: felt,
        degree: felt,
        // was thinking about a1*X + a2*X^2 + a3*X^3 + b1*Y + b2*Y^2 + b3*Y^3 + ... 
        // but how about cross product like XY, XY^2
        // maybe this is where computational graph like ONNX plays role?
    }
}