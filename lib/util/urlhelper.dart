class Urlhelper {

  static String adjustUrl(String url){
final isGoodCondition = ['http://','https://'].any((e)=>url.contains(e));
final isStartNumber = RegExp(r'^[0-9]').hasMatch(url);

if(isGoodCondition) return url;

if (isStartNumber) return 'http://$url';

return 'https://$url';

    
  }
  
}