import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/profile/data_model/membership_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import 'membership_form_provider.dart';
import 'membership_form_repository.dart';

class MembershipFormController {
  late MembershipFormProvider membershipProvider;
  late MembershipFormRepository membershipFormRepository;

  MembershipFormController({required this.membershipProvider, MembershipFormRepository? repository}) {
    membershipFormRepository = repository ?? MembershipFormRepository();
  }

  Future<void> getAllMembershipFormList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<MembershipModel> MembershipFormList = [];
    MembershipFormList = await membershipFormRepository.getMembershipFormListRepo();
    if (MembershipFormList.isNotEmpty) {
      membershipProvider.membershipFormList.setList(list: MembershipFormList);
    }
  }

  Future<List<MembershipModel>> getMembershipFormPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getMembershipFormPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    MembershipFormProvider provider = membershipProvider;

    if (!isRefresh && isFromCache && provider.allMembershipFormLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.membershipFormList.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreMembershipForm.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastMembershipFormDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isMembershipFormFirstTimeLoading.set(value: true, isNotify: false);
      provider.isMembershipFormLoading.set(value: false, isNotify: false);
      provider.membershipFormList.setList(list: <MembershipModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreMembershipForm.get()) {
        MyPrint.printOnConsole('No More MembershipForm', tag: tag);
        return provider.membershipFormList.getList(isNewInstance: true);
      }
      if (provider.isMembershipFormLoading.get()) return provider.membershipFormList.getList(isNewInstance: true);

      provider.isMembershipFormLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.membershipCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastMembershipFormDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for MembershipForm:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreMembershipForm.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastMembershipFormDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<MembershipModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          MembershipModel productModel = MembershipModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.membershipFormList.setList(list: list, isClear: false, isNotify: false);
      provider.isMembershipFormFirstTimeLoading.set(value: false, isNotify: true);
      provider.isMembershipFormLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final MembershipForm Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final MembershipForm Length in Provider:${provider.allMembershipFormLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getMembershipFormPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.membershipFormList.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreMembershipForm.set(value: true, isNotify: false);
      provider.lastMembershipFormDocument.set(value: null, isNotify: false);
      provider.isMembershipFormFirstTimeLoading.set(value: false, isNotify: false);
      provider.isMembershipFormLoading.set(value: false, isNotify: true);
      return [];
    }
  }
}
