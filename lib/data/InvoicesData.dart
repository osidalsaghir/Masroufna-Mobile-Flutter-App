class Invoice {
  int amount;
  String description;
  String user;
  String invoiceId;
  String picture;

  Invoice(
      this.amount, this.description, this.user, this.invoiceId, this.picture);
  toJson() {
    return {
      "amount": amount,
      "des": description,
      "user": user,
      "picture": picture,
    };
  }
}
