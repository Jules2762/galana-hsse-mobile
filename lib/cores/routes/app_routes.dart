import 'package:flutter/material.dart';
import 'package:gestion_hsse/views/auth/forgot_password_page.dart';
import 'package:gestion_hsse/views/auth/login_page.dart';
import 'package:gestion_hsse/views/auth/reset_password_page.dart';
import 'package:gestion_hsse/views/home/inspection/checklist_detail_page.dart';
import 'package:gestion_hsse/views/home/inspection/corrective_action_page.dart';
import 'package:gestion_hsse/views/home/inspection/inspection_question_page.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_detail_page.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/vmc_detail_page.dart';
import 'package:gestion_hsse/views/home/profile/change_password_page.dart';
import 'package:gestion_hsse/views/home/profile/edit_profile_page.dart';
import 'package:gestion_hsse/views/home/rapport/report_details_page.dart';
import 'package:gestion_hsse/views/home/settings/settings_page.dart';

import 'package:gestion_hsse/views/layouts/home_layout.dart';

class AppRoutes {
  static const String login = "/";
  static const String forgotPassword = "/forgot-password";
  static const String resetPassword = "/reset-password";
  static const String home = "/home";
  static const String checklistDetail = "/checklist-detail";
  static const String inspectionQuestion ="/inspection-question";
  static const String correctiveAction ="/corrective-action";
  static const String settings ="/settings";
  static const String reportDetails ="/report-details";
  static const String editProfile ="/edit-profile";
  static const String changePassword ="/change-password";
  static const String equipmentDetail = "/equipment-detail";
  static const String vmcDetail = "/vmc-detail";
  static const String inspections = "/inspections";

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    forgotPassword: (_) => const ForgotPasswordPage(),
    resetPassword: (_) => const ResetPasswordPage(),
    home: (_) => const HomeLayout(),
    inspections: (_) => const HomeLayout(initialIndex: 1),
    checklistDetail: (_) => const ChecklistDetailPage(),
    inspectionQuestion: (_) => const InspectionQuestionPage(),
    correctiveAction: (_) => const CorrectiveActionPage(),
    settings: (_) => const SettingsPage(),
    reportDetails: (_) => const ReportDetailPage(),
    editProfile: (_) => const EditProfilePage(),
    changePassword: (_) => const ChangePasswordPage(),
    equipmentDetail: (_) => const EquipmentDetailPage(),
    vmcDetail: (_) => const VmcDetailPage(),
  };
}