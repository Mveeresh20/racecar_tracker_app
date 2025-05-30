class AppConstant {
  // static const String baseUrl =  "https://api.stentryplatform.info/"; //PRODUCTION URL
  static const String baseUrl =
      "https://d1r9c4nksnam33.cloudfront.net/"; //Test URL
  static const String baseUrlForUploadPostApi = "${baseUrl}upload";

  static const String bundleNameForPostAPI = "478"; //Test
  static const String bundleNameToFetchImage = "478/"; //Test

  // static const String bundleNameForPostAPI = ""; //Prod
  // static const String bundleNameToFetchImage = ""; //Prod

  static const String usersFolder = "users";
  static const String categoriesFolder = "categories";
  static const String postsFolder = "posts";

  static const String baseUrlToFetchStaticImage =
      "$baseUrl$bundleNameToFetchImage";
  static const String baseUrlToUploadAndFetchUsersImage =
      "$baseUrl${bundleNameToFetchImage}upload";
  static const String appName = "Racecar Tracker";
  // https://d1r9c4nksnam33.cloudfront.net/w12/images/mindfulness11.png ///fetch image

  static String getUserProfileImagePath(String userId) =>
      "$usersFolder/$userId/profile";
  static String getCategoryImagePath(String categoryId) =>
      "$categoriesFolder/$categoryId";
  static String getPostImagePath(String postId) => "$postsFolder/$postId";
}
