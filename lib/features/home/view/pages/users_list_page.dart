import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  Set<String> selectedNames = {};

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedRole = "All";
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? lastDeletedUser;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(_filterUsers);
  }

  Future<void> fetchUsers() async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse('${ServerConstant.serverURL}/auth/get-users');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(json.decode(response.body));
          filteredUsers = users;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch users: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  void _filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users
          .where((user) =>
              user["name"].toLowerCase().contains(query) &&
              (selectedRole == "All" ||
                  user["role"].toLowerCase() == selectedRole.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteUser(String userId) async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url =
        Uri.parse('${ServerConstant.serverURL}/auth/delete-user/$userId');

    try {
      final deletedUser = users.firstWhere((user) => user["id"] == userId);
      lastDeletedUser = deletedUser;

      final response = await http.delete(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          users.removeWhere((user) => user["id"] == userId);
          filteredUsers.removeWhere((user) => user["id"] == userId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✅ User deleted successfully!"),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () => _undoDelete(),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to delete user: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> _undoDelete() async {
    if (lastDeletedUser == null) return;

    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse('${ServerConstant.serverURL}/auth/restore-user');

    try {
      final response = await http.post(
        url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": lastDeletedUser!["id"],
          "name": lastDeletedUser!["name"],
          "email": lastDeletedUser!["email"],
          "role": lastDeletedUser!["role"],
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          users.add(lastDeletedUser!);
          filteredUsers.add(lastDeletedUser!);
          lastDeletedUser = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ User restored successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to restore user: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Pallete.whiteColor,
            size: 35,
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        title: Text(
          "Users List (${filteredUsers.length})",
          style: TextStyle(
              color: Pallete.whiteColor,
              fontSize: 23,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Pallete.transparentColor,
      ),
      body: RefreshIndicator(
        onRefresh: fetchUsers,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                style: TextStyle(color: Pallete.whiteColor),
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: const TextStyle(color: Pallete.whiteColor),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Pallete.whiteColor,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Filter by Role:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Pallete.whiteColor)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedRole,
                    dropdownColor: Pallete.backgroundColor,
                    style: const TextStyle(color: Pallete.whiteColor),
                    onChanged: (newValue) {
                      setState(() {
                        selectedRole = newValue!;
                        _filterUsers();
                      });
                    },
                    items: ["All", "Admin", "User"].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Text(errorMessage!,
                              style: const TextStyle(color: Colors.red)))
                      : filteredUsers.isEmpty
                          ? const Center(
                              child: Text(
                                "No users found!",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return ListTile(
                                  leading: const Icon(Icons.person,
                                      color: Colors.blueAccent),
                                  title: Text(user["name"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Pallete.whiteColor)),
                                  subtitle: Text(user["email"]),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user["role"].toUpperCase(),
                                        style: TextStyle(
                                          color: user["role"] == "admin"
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (user["role"] != "admin")
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                  user["id"]),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteUser(userId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
