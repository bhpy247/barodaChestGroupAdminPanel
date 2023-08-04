import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/admin/property_model.dart';
import '../../models/other/data_model/faq_model.dart';
import '../../models/other/data_model/feedback_model.dart';
import '../common/common_provider.dart';

class AdminProvider extends CommonProvider{
  AdminProvider() {
    propertyModel = CommonProviderPrimitiveParameter<PropertyModel?>(
      value: null,
      notify: notify,
    );
    timeStamp = CommonProviderPrimitiveParameter<Timestamp?>(
      value: null,
      notify: notify,
    );
    faqList = CommonProviderListParameter<FAQModel>(
      list: <FAQModel>[],
      notify: notify,
    );
    feedbackList = CommonProviderListParameter<FeedbackModel>(
      list: <FeedbackModel>[],
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<PropertyModel?> propertyModel;
  late CommonProviderPrimitiveParameter<Timestamp?> timeStamp;

  late CommonProviderListParameter<FAQModel> faqList;
  late CommonProviderListParameter<FeedbackModel> feedbackList;

  void reset({bool isNotify = true}) {
    propertyModel.set(value: null, isNotify: false);
    timeStamp.set(value: null, isNotify: false);

    faqList.setList(list: [], isClear: true, isNotify: false);
    feedbackList.setList(list: [], isClear: true, isNotify: isNotify);
  }
}