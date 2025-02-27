import 'package:flutter/material.dart';
import 'package:foodrecipeapp/app/modules/member/views/payment_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/colors.dart';

class CardPaymentItems extends StatelessWidget {
  const CardPaymentItems({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PaymentView()),
      child: Padding(
        padding: const EdgeInsets.only(right: 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 0, 10),
          width: Get.width,
          decoration: BoxDecoration(
            color: hijauSage.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pay Premium!",
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      color: bgColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "AYO BAYAR PREMIUM\nDownload Resep Premium nyaan~",
                    style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: bgColor,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),

              // * AVATAR
              Image.asset(
                "assets/images/avatarCard_img.png",
                width: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}
