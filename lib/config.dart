String parseErrorMessage(Map<String, dynamic> responseData) {
  if (responseData.containsKey('errors')) {
    List errors = responseData['errors'];
    return errors.map((e) => e['msg']).join('\n');
  } else if (responseData.containsKey('massage')) {
    return responseData['massage'];
  } else if (responseData.containsKey('message')) {
    return responseData['message'];
  } else {
    return 'Unknown error occurred';
  }
}