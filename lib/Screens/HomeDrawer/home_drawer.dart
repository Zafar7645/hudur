import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hudur/Components/api.dart';
import 'package:hudur/Components/colors.dart';
import 'package:hudur/Components/models.dart';
import 'package:hudur/Screens/AdministrativeLeaves/administrative_leaves.dart';
import 'package:hudur/Screens/BenchList/benchlist_page.dart';
import 'package:hudur/Screens/CheckInHistory/check_in_history.dart';
import 'package:hudur/Screens/Enquiry/enquiry_chat.dart';
import 'package:hudur/Screens/Enquiry/enquiry_page.dart';
import 'package:hudur/Screens/LateCheckInReason/late_reason.dart';
import 'package:hudur/Screens/RelatedSites/related_sites.dart';
import 'package:hudur/Screens/Services/services.dart';

class HomeDrawer extends StatelessWidget {
  final UserModel userModel;
  const HomeDrawer({Key key, this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: FutureBuilder(
          future: AllApi().getCompanyDetails(companyid: userModel.companyId),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white,),
              );
            }

            var companydetails = snapshot.requireData;


            return Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  color: portica,
                  child: Image.network(
                    '${adminurl}/assets/images/company/logo/${companydetails['image']}',
                    fit:BoxFit.fill,
                    loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null ?
                          loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.find_replace_rounded,
                          color: portica,
                        ),
                        title: const Text('Bench List'),
                        onTap: () {
                          Get.to(
                            BenchList(
                              userModel: userModel,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.web_asset_rounded,
                          color: portica,
                        ),
                        title: const Text('Related Sites'),
                        onTap: () {
                          Get.to(RelatedSites(
                            userModel: userModel,
                          ));
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.history,
                          color: portica,
                        ),
                        title: const Text('Check-In History'),
                        onTap: () {
                          Get.to(
                            CheckInHistory(
                              userModel: userModel,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.chat_bubble_rounded,
                          color: portica,
                        ),
                        title: const Text('Enquiry'),
                        onTap: () {
                          // Get.to(
                          //   Enquiry(
                          //     userModel: userModel,
                          //   ),
                          // );
                          Get.to(
                            () => EnquiryChat(
                              userModel: userModel,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: portica,
                        ),
                        title: const Text('Administrative Leaves'),
                        onTap: () {
                          Get.to(
                            AdministrativeLeaves(
                              userModel: userModel,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.room_service_rounded,
                          color: portica,
                        ),
                        title: const Text('Services'),
                        onTap: () {
                          Get.to(
                            () => Services(
                              userModel: userModel,
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
