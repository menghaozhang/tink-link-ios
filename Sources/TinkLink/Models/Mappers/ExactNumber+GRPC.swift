extension ExactNumber {
    init(value: GRPCExactNumber) {
        self.scale = value.scale
        self.unscaledValue = value.unscaledValue
    }
}
