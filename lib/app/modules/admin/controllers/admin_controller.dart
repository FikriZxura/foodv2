import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:foodrecipeapp/app/StorageService.dart';
import 'package:foodrecipeapp/app/models/premium_list.dart';
import 'package:foodrecipeapp/app/models/resep.dart';
import 'package:foodrecipeapp/app/modules/admin/views/resepPremium/managementResepPremium_view.dart';
import 'package:foodrecipeapp/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../models/listMember.dart';
import '../../../models/transaction.dart';
import '../../../widgets/colors.dart';
import '../../home/recipe_service.dart';
import '../admin_service.dart';
import '../views/resep/managementResep_view.dart';

class AdminController extends GetxController {
  var recipes = <Resep>[].obs; // Observable list of Resep
  var transactions = <Transaction>[].obs;
  var premiums = <PremiumList>[].obs;
  var members = <ListMember>[].obs;

  RxBool isFavorite = false.obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  final StorageService _storage = StorageService();
  final RecipeService recipeService = RecipeService();
  final AdminService _adminService = AdminService();

  @override
  void onInit() {
    super.onInit();
    final token = _storage.readToken();
    isLoggedIn(token != null);
  }
  // ! BAGIAN ADMIN HANDLING
  // Future<void> loginAdmin(String username, String password) async {
  //   isLoading(true);
  //   final token = await AdminService.loginAdmin(username, password);
  //   if (token != null) {
  //     _storage.writeToken(token);
  //     isLoggedIn(true);
  //     Get.offAllNamed(Routes.ADMIN);
  //   } else {
  //     Get.snackbar('Error', 'Login gagal');
  //   }
  //   isLoading(false);
  // }

  Future<void> loginAdmin(String username, String password) async {
    if (username.isEmpty) {
      Get.snackbar('Error', 'Username tidak boleh kosong');
      return;
    }
    if (password.isEmpty) {
      Get.snackbar('Error', 'Password tidak boleh kosong');
      return;
    }

    isLoading(true);

    try {
      final token = await AdminService.loginAdmin(username, password);

      if (token != null) {
        _storage.writeToken(token);
        isLoggedIn(true);
        Get.offAllNamed(Routes.ADMIN);
        Get.snackbar('Success', 'Login berhasil');
      } else {
        // Assume the error is incorrect password
        Get.snackbar('Error', 'Password salah');
      }
    } catch (e) {
      // Assume the error is incorrect username
      Get.snackbar('Error', 'Username atau Password salah');
    } finally {
      isLoading(false);
    }
  }

  Future<void> logoutAdmin() async {
    isLoading(true);
    await _adminService.logout();
    _storage.removeToken();
    isLoggedIn(false);
    isLoading(false);
    Get.offAllNamed(Routes.HOME);
    Get.snackbar("Success", "Logout Berhasil");
  }
  // ! AKHIR BAGIAN ADMIN HANDLING

  // ! BAGIAN RESEP
  void fetchAllRecipes() async {
    try {
      isLoading(true);
      List<dynamic> result = await recipeService.getListRecipe();
      recipes.assignAll(result.map((item) => Resep.fromJson(item)));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch recipes');
    } finally {
      isLoading(false);
    }
  }

  void addFood(Resep food) async {
    isLoading(true);
    final token = StorageService().readToken();
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/recipe'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'API-TOKEN': token!,
      },
      body: jsonEncode(food.toJson()),
    );

    try {
      if (response.statusCode == 200) {
        recipes.add(food);
        Get.snackbar('Success', 'Recipe added successfully',
            snackPosition: SnackPosition.BOTTOM);
        isLoading(false);
        Get.off(() => ManagementResep());
      } else {
        isLoading(false);
        print('Failed to add food: ${response.body}');
        Get.snackbar('Error', 'Failed to add food',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add food',
          snackPosition: SnackPosition.BOTTOM);
      isLoading(false);
    }
  }

  Future<void> editFood(int index, Resep newFood) async {
    isLoading(true);
    final response = await _adminService.editFood(index, newFood);
    if (response) {
      Get.snackbar('Success', 'Recipe updated successfully',
          snackPosition: SnackPosition.BOTTOM);
      // Get.to(() => ManagementResep());
      Get.off(() => ManagementResep());
    } else {
      Get.snackbar('Error', 'Failed to update food',
          snackPosition: SnackPosition.BOTTOM);
    }
    isLoading(false);
  }

  void deleteFood(int index) async {
    final token = StorageService().readToken();
    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/recipe/$index'),
      headers: {
        'API-TOKEN': token!,
      },
    );
    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Recipe deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
      fetchAllRecipes();
    } else {
      Get.snackbar('Error', 'Failed to delete recipe',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  // ! AKHIR BAGIAN RESEP

  // * BAGIAN TRANSACTION
  Future<void> fetchTransactions() async {
    try {
      isLoading(true);

      List<Transaction> result = await _adminService.fetchTransactions();

      transactions.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteTransaction(int id) async {
    isLoading(true);

    final response = await _adminService.deleteTransaction(id);
    if (response) {
      Get.snackbar('Success', 'Transaction deleted successfully');
      isLoading(false);
      fetchTransactions();
    } else {
      Get.snackbar('Error', 'Failed to delete transaction');
      isLoading(false);
    }
  }

  // * AKHIR BAGIAN TRANSACTION

  // * BAGIAN PREMIUM
  void fetchAllPremiums() async {
    try {
      isLoading(true);
      List<PremiumList> result = await _adminService.getListPremium();
      premiums.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch premiums');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> editPremium(int id, String premiumName) async {
    isLoading(true);
    try {
      final success = await _adminService.editPremium(id, premiumName);
      if (success) {
        Get.snackbar('Success', 'Premium name updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: hijauSage,
            colorText: Colors.white);
        isLoading(false);
        Get.off(() => ManagementResepPremium());
        return success;
      } else {
        Get.snackbar('Error', 'Failed to update premium name',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> addPremiumWithPdf(PlatformFile file) async {
    try {
      isLoading(true);
      final response = await _adminService.uploadFile(file);
      if (response) {
        Get.snackbar('Success', "Success Upload File",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: hijauSage,
            colorText: Colors.white);
        isLoading(false);
        Get.off(() => ManagementResepPremium());
      }
    } catch (e) {
      throw e;
    }
  }

  void deletePremium(int index) async {
    final response = await _adminService.deletePremium(index);
    if (response) {
      Get.snackbar('Success', 'Premium recipe deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
      fetchAllPremiums();
    } else {
      Get.snackbar('Error', 'Failed to delete premium recipe',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<PremiumList> getPremiumById(int id) async {
    try {
      final premium = await _adminService.getPremiumById(id);
      return premium;
    } catch (e) {
      throw Exception('Failed to load premium');
    }
  }
  // * AKHIR BAGIAN PREMIUM

  // * BAGIAN MEMBER
  Future<void> fetchAllMembers() async {
    try {
      isLoading(true);
      List<ListMember> result = await _adminService.getListMembers();
      members.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch members');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateMember(String username, bool premium) async {
    final member =
        members.firstWhere((element) => element.username == username);
    member.premium = premium;
    isLoading(true);
    final response = await _adminService.updateMember(member);
    if (response) {
      Get.snackbar('Success', 'Member updated successfully',
          snackPosition: SnackPosition.BOTTOM);
      fetchAllMembers();
    } else {
      Get.snackbar('Error', 'Failed to update member',
          snackPosition: SnackPosition.BOTTOM);
    }
    isLoading(false);
  }

  void deleteMember(String username) async {
    isLoading(true);
    final response = await _adminService.deleteMember(username);
    if (response) {
      Get.snackbar('Success', 'Member deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
      fetchAllMembers();
    } else {
      Get.snackbar('Error', 'Failed to delete member',
          snackPosition: SnackPosition.BOTTOM);
    }
    isLoading(false);
  }
}
