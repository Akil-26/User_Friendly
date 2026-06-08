import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _builtInInterests = [
    'tech', 'sports', 'finance', 'science', 'health',
    'politics', 'world', 'business', 'entertainment', 'gaming', 'india',
  ];

  late List<String> _selectedInterests;
  late List<String> _allInterests;
  bool _hasChanges = false;
  final _customInterestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    _selectedInterests = state is AuthAuthenticated
        ? List.from(state.user.interests)
        : [];
    // merge built-in + user custom interests
    _allInterests = {
      ..._builtInInterests,
      ..._selectedInterests,
    }.toList();
  }

  @override
  void dispose() {
    _customInterestController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        if (_selectedInterests.length > 1) {
          _selectedInterests.remove(interest);
          _hasChanges = true;
        } else {
          _showSnack('Keep at least one interest', isError: true);
        }
      } else {
        _selectedInterests.add(interest);
        _hasChanges = true;
      }
    });
  }

  void _addCustomInterest() {
    final val = _customInterestController.text.trim().toLowerCase();
    if (val.isEmpty) return;
    if (_allInterests.contains(val)) {
      _showSnack('Already exists', isError: true);
      return;
    }
    setState(() {
      _allInterests.add(val);
      _selectedInterests.add(val);
      _hasChanges = true;
    });
    _customInterestController.clear();
  }

  void _saveInterests() {
    context.read<AuthBloc>().add(AuthInterestsUpdated(_selectedInterests));
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontSize: 13.sp)),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showChangePasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();
    bool obscure1 = true, obscure2 = true, obscure3 = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheet) => Padding(
              padding: EdgeInsets.all(AppSizes.spaceLg),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(77), // 30% opacity
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceLg),
                    Text(
                      'Change password',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: kDarkText,
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceLg),
                    AppTextField(
                      controller: currentCtrl,
                      label: 'Current password',
                      prefixIcon: Icons.lock_outlined,
                      obscureText: obscure1,
                      suffix: IconButton(
                        icon: Icon(
                          obscure1
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: kGrayText,
                        ),
                        onPressed: () =>
                            setSheet(() => obscure1 = !obscure1),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: AppSizes.spaceMd),
                    AppTextField(
                      controller: newCtrl,
                      label: 'New password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: obscure2,
                      suffix: IconButton(
                        icon: Icon(
                          obscure2
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: kGrayText,
                        ),
                        onPressed: () =>
                            setSheet(() => obscure2 = !obscure2),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.spaceMd),
                    AppTextField(
                      controller: confirmCtrl,
                      label: 'Confirm new password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: obscure3,
                      suffix: IconButton(
                        icon: Icon(
                          obscure3
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: kGrayText,
                        ),
                        onPressed: () =>
                            setSheet(() => obscure3 = !obscure3),
                      ),
                      validator: (v) {
                        if (v != newCtrl.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.spaceLg),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthPasswordChanged ||
                            state is AuthAuthenticated) {
                          Navigator.pop(ctx);
                          _showSnack('Password changed ✅');
                        }
                        if (state is AuthError) {
                          _showSnack(state.message, isError: true);
                        }
                      },
                      builder: (context, state) => AppButton(
                        label: 'Change password',
                        isLoading: state is AuthLoading,
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            context
                                .read<AuthBloc>()
                                .add(AuthPasswordChangeRequested(
                                  currentPassword: currentCtrl.text,
                                  newPassword: newCtrl.text,
                                ));
                          }
                        },
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceLg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: AlertDialog(
          backgroundColor: kBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Delete account',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This action is permanent and cannot be undone. All your data will be deleted.',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: kGrayText,
                ),
              ),
              SizedBox(height: AppSizes.spaceMd),
              AppTextField(
                controller: passCtrl,
                label: 'Enter your password',
                prefixIcon: Icons.lock_outlined,
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: kGrayText),
              ),
            ),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
                if (state is AuthError) {
                  _showSnack(state.message, isError: true);
                }
              },
              builder: (context, state) => TextButton(
                onPressed: state is AuthLoading
                    ? null
                    : () => context.read<AuthBloc>().add(
                          AuthAccountDeleteRequested(passCtrl.text),
                        ),
                child: state is AuthLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveInterests,
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated && _hasChanges) {
            setState(() => _hasChanges = false);
            _showSnack('Interests updated ✅');
          }
          if (state is AuthError) {
            _showSnack(state.message, isError: true);
          }
          if (state is AuthUnauthenticated) {
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        },
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }
          final user = state.user;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── User card ───────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizes.spaceLg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13), // 5% opacity
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: kPrimaryColor,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.inter(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: kDarkText,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              user.email,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: kGrayText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.spaceXl),

                // ── Interests ───────────────────────────────
                Row(
                  children: [
                    Text(
                      'Your interests',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: kDarkText,
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceSm),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(
                            AppSizes.radiusCircular),
                      ),
                      child: Text(
                        '${_selectedInterests.length}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Tap to add or remove. Add your own below.',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: kGrayText,
                  ),
                ),
                SizedBox(height: AppSizes.spaceMd),

                // All interests (built-in + custom)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _allInterests.map((interest) {
                    return AppChip(
                      label: interest,
                      isSelected: _selectedInterests.contains(interest),
                      onTap: () => _toggleInterest(interest),
                    );
                  }).toList(),
                ),
                SizedBox(height: AppSizes.spaceMd),

                // Custom interest input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customInterestController,
                        style: GoogleFonts.inter(fontSize: 14.sp),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addCustomInterest(),
                        decoration: InputDecoration(
                          hintText: 'Add custom interest...',
                          hintStyle: GoogleFonts.inter(
                            color: kGrayText,
                            fontSize: 13.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg),
                            borderSide: BorderSide(
                                color: Colors.grey.withAlpha(51)), // 20% opacity
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg),
                            borderSide: BorderSide(
                                color: Colors.grey.withAlpha(51)), // 20% opacity
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg),
                            borderSide: const BorderSide(
                                color: kPrimaryColor, width: 1.5),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSizes.spaceMd,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceSm),
                    GestureDetector(
                      onTap: _addCustomInterest,
                      child: Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.spaceXl),

                // Save button
                if (_hasChanges) ...[
                  AppButton(
                    label: 'Save interests',
                    isLoading: state is AuthLoading,
                    onTap: _saveInterests,
                  ),
                  SizedBox(height: AppSizes.spaceMd),
                ],

                // ── Account settings ─────────────────────────
                Text(
                  'Account',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: kDarkText,
                  ),
                ),
                SizedBox(height: AppSizes.spaceMd),

                // Change password
                _settingsTile(
                  icon: Icons.lock_outline,
                  label: 'Change password',
                  onTap: _showChangePasswordSheet,
                ),
                SizedBox(height: AppSizes.spaceSm),

                // Logout
                _settingsTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: kBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      title: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        'Are you sure you want to logout?',
                        style:
                            GoogleFonts.inter(color: kGrayText),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel',
                              style:
                                  GoogleFonts.inter(color: kGrayText)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context
                                .read<AuthBloc>()
                                .add(AuthLogoutRequested());
                          },
                          child: Text(
                            'Logout',
                            style: GoogleFonts.inter(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spaceSm),

                // Delete account
                _settingsTile(
                  icon: Icons.delete_outline,
                  label: 'Delete account',
                  isDestructive: true,
                  onTap: _showDeleteAccountDialog,
                ),

                SizedBox(height: AppSizes.spaceXl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : kDarkText;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: AppSizes.spaceMd,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withAlpha(77) // 30% opacity
                : Colors.grey.withAlpha(38), // 15% opacity
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: AppSizes.spaceMd),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: isDestructive
                  ? Colors.red.withAlpha(128) // 50% opacity
                  : kGrayText,
            ),
          ],
        ),
      ),
    );
  }
}