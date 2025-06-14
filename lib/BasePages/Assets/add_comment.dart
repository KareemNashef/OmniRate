// ==================== Add Comment Modal ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Shared/utils.dart';

// ========== Add Comment Modal Class ========== //

class AddCommentModal extends StatefulWidget {
  // ===== Input Variables ===== //
  final void Function(String comment) onSubmit;
  final String mediaType;
  final String mediaID;
  final String? existingComment; // For editing existing comments

  // ===== Constructor ===== //
  const AddCommentModal({
    super.key,
    required this.onSubmit,
    required this.mediaType,
    required this.mediaID,
    this.existingComment,
  });

  @override
  State<AddCommentModal> createState() => _AddCommentModalState();
}

class _AddCommentModalState extends State<AddCommentModal> {
  // ===== Class Variables ===== //

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool isLoading = false;
  
  // Character limits
  static const int maxCharacters = 500;
  static const int minCharacters = 10;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    
    // Pre-fill if editing existing comment
    if (widget.existingComment != null) {
      _commentController.text = widget.existingComment!;
    }
    
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // ===== Class Methods ===== //

  bool get isCommentValid {
    final text = _commentController.text.trim();
    return text.length >= minCharacters && text.length <= maxCharacters;
  }

  bool get hasChanges {
    return _commentController.text.trim() != (widget.existingComment ?? '');
  }

  void _submitComment() {
    if (!isCommentValid) return;

    setState(() {
      isLoading = true;
    });

    // Simulate submission delay (remove in production)
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onSubmit(_commentController.text.trim());
      Navigator.pop(context);
    });
  }

  // ===== Class Widgets ===== //

  Widget commentTextField() {
    return Container(
      decoration: BoxDecoration(
        gradient: gradientContainer(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _commentController,
        focusNode: _commentFocusNode,
        maxLines: 6,
        maxLength: maxCharacters,
        textInputAction: TextInputAction.newline,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: 'Share your thoughts about this ${widget.mediaType.split('.').last}...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
          counterStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget commentGuidelines() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Keep it respectful and constructive. Minimum $minCharacters characters required.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget characterCounter() {
    final currentLength = _commentController.text.length;
    final isValid = currentLength >= minCharacters;
    final isOverLimit = currentLength > maxCharacters;
    
    Color counterColor;
    if (isOverLimit) {
      counterColor = Theme.of(context).colorScheme.error;
    } else if (isValid) {
      counterColor = Theme.of(context).colorScheme.primary;
    } else {
      counterColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isValid ? 'Ready to submit' : 'Need ${minCharacters - currentLength} more characters',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: counterColor,
            fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        Text(
          '$currentLength/$maxCharacters',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: counterColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget actionButtons() {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Padding
        const SizedBox(width: 12),

        // Submit Button
        Expanded(
          child: Container(
            decoration: buttonDecoration(context),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (!isCommentValid || isLoading) ? null : _submitComment,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            widget.existingComment != null ? 'Update Comment' : 'Submit Comment',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: (!isCommentValid || isLoading)
                                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
                                  : null,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Container(
      // Theme
      decoration: BoxDecoration(
        gradient: gradientBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),

      // Padding
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),

      // Content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Padding
          const SizedBox(height: 20),

          // Title
          sectionHeader(
            context,
            widget.existingComment != null ? 'Edit Comment' : 'Add Comment',
            'Share your thoughts about this ${widget.mediaType.split('.').last}',
          ),

          // Padding
          const SizedBox(height: 16),

          // Comment guidelines
          commentGuidelines(),

          // Padding
          const SizedBox(height: 16),

          // Comment text field
          commentTextField(),

          // Padding
          const SizedBox(height: 8),

          // Character counter
          characterCounter(),

          // Padding
          const SizedBox(height: 16),

          // Action buttons
          actionButtons(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}