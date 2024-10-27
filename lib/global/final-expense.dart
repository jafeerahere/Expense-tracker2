import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    required this.title,
    required this.hint,
    this.controller,
  });
  final TextEditingController? controller;
  String title;
  String hint;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 5,
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xff827C7C),
                      width: 1,
                    )),
                hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff827C7C)),
                hintText: hint),
          )
        ],
      ),
    );
  }
}
