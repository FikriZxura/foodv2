import 'package:flutter/material.dart';
import 'package:foodrecipeapp/app/modules/admin/views/member/managementMember_view.dart';
import 'package:foodrecipeapp/app/modules/admin/views/resep/managementResep_view.dart';
import 'package:foodrecipeapp/app/modules/admin/views/resepPremium/managementResepPremium_view.dart';
import 'package:foodrecipeapp/app/modules/admin/views/transaction/transaction_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/colors.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if not logged in
    if (!controller.isLoggedIn.value) {
      // Redirect to HOME
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offNamed(Routes.HOME);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restricted Area : Admin Panel',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: hijauSage,
        leading: IconButton(
            onPressed: () => Get.offAllNamed(Routes.HOME),
            icon: Icon(Iconsax.home5)),
        actions: [
          IconButton(
              onPressed: () {
                controller.logoutAdmin();
              },
              icon: const Icon(Iconsax.logout5))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AdminButton(
              label: 'Recipe',
              onPressed: () {
                Get.to(() => const ManagementResep());
              },
            ),
            const SizedBox(height: 20),
            AdminButton(
              label: 'Recipe Premium',
              onPressed: () {
                Get.to(() => const ManagementResepPremium());
              },
            ),
            const SizedBox(height: 20),
            AdminButton(
              label: 'Member',
              onPressed: () {
                Get.to(() => ManagementMemberView());
              },
            ),
            const SizedBox(height: 20),
            AdminButton(
              label: 'Transaction',
              onPressed: () {
                Get.to(() => TransactionView());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AdminButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  // ignore: use_super_parameters
  const AdminButton({Key? key, required this.label, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: hijauSage,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle:
            GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: Center(
        child: Text(label),
      ),
    );
  }
}
