import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';
import '../domain/draft_overview.dart';

class DraftOverviewCard extends StatelessWidget {
  const DraftOverviewCard({
    super.key,
    required this.overview,
    required this.onOpen,
    this.loading = false,
    this.failed = false,
    this.preview = false,
    this.onRefresh,
  });
  final DraftOverview? overview;
  final VoidCallback onOpen;
  final VoidCallback? onRefresh;
  final bool loading;
  final bool failed;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final summary = overview;
    return Container(
      key: const ValueKey('draftOverview'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4, right: 12),
                child: Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              Expanded(
                child: Text(
                  preview ? text.overviewPreviewTitle : text.overviewTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  onPressed: loading ? null : onRefresh,
                  tooltip: text.overviewRefresh,
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (preview) ...[
            Text(
              text.overviewPreviewNotice,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
          ],
          if (loading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(text.overviewLoading),
          ] else if (failed) ...[
            Text(text.overviewFailed),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRefresh, child: Text(text.retry)),
          ] else if (summary == null) ...[
            Text(
              text.overviewEmpty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(text.overviewEmptyBody),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onOpen, child: Text(text.overviewStart)),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                text.overviewDraftStatus,
                style: const TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              summary.hasRequiredDetails
                  ? text.overviewRequiredComplete
                  : text.overviewRequiredPending,
            ),
            const SizedBox(height: 8),
            Text(
              text.draftSavedDate(
                MaterialLocalizations.of(
                  context,
                ).formatCompactDate(summary.updatedAt.toLocal()),
              ),
            ),
            const SizedBox(height: 8),
            Text(text.overviewNotSent),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onOpen,
              child: Text(preview ? text.overviewExplore : text.overviewResume),
            ),
          ],
        ],
      ),
    );
  }
}
