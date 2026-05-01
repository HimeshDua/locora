bool isAdmin(String email) {
  switch (email) {
    case "admin@gmail.com" || "himeshdua22@gmail.com":
      return true;
    default:
      return false;
  }
}
