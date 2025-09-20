import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../services/progress_service.dart';
import '../providers/auth_provider.dart';

class NotesResourcesSection extends StatefulWidget {
  final Lesson lesson;
  final List<String> resources;

  const NotesResourcesSection({
    super.key,
    required this.lesson,
    this.resources = const [],
  });

  @override
  State<NotesResourcesSection> createState() => _NotesResourcesSectionState();
}

class _NotesResourcesSectionState extends State<NotesResourcesSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id ?? 'anonymous';
    final notes = ProgressService.getLessonNote(widget.lesson.id, userId);

    if (notes != null) {
      _notesController.text = notes;
    }
  }

  Future<void> _saveNotes() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id ?? 'anonymous';

    await ProgressService.saveLessonNote(
      widget.lesson.id,
      userId,
      _notesController.text,
    );

    setState(() {
      _isEditingNotes = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteNotes() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id ?? 'anonymous';

    await ProgressService.deleteLessonNote(widget.lesson.id, userId);
    _notesController.clear();

    setState(() {
      _isEditingNotes = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(
                  icon: Icon(Icons.note_outlined),
                  text: 'Notes',
                ),
                Tab(
                  icon: Icon(Icons.folder_outlined),
                  text: 'Resources',
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotesTab(),
                _buildResourcesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            children: [
              Text(
                'Lesson Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (!_isEditingNotes) ...[
                IconButton(
                  onPressed: () => setState(() => _isEditingNotes = true),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit notes',
                ),
                if (_notesController.text.isNotEmpty)
                  IconButton(
                    onPressed: _deleteNotes,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete notes',
                  ),
              ] else ...[
                IconButton(
                  onPressed: _saveNotes,
                  icon: const Icon(Icons.save_outlined),
                  tooltip: 'Save notes',
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _isEditingNotes = false);
                    _loadNotes(); // Reset to saved notes
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  tooltip: 'Cancel',
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Notes content
          Expanded(
            child: _isEditingNotes
                ? TextField(
                    controller: _notesController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Write your notes here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                    child: _notesController.text.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_add_outlined,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notes yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the edit button to add your notes',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Text(
                            _notesController.text,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    final resources =
        widget.resources.isNotEmpty ? widget.resources : _getMockResources();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lesson Resources',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: resources.isEmpty
                ? _buildEmptyResources()
                : ListView.builder(
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      return _buildResourceItem(resource, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResources() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No resources available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Instructors can add resources like PDFs, documents, and links',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String resource, int index) {
    final isPdf = resource.toLowerCase().endsWith('.pdf');
    final isDocument = resource.toLowerCase().endsWith('.doc') ||
        resource.toLowerCase().endsWith('.docx');
    final isLink = resource.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _handleResourceTap(resource),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getResourceColor(isPdf, isDocument, isLink),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getResourceIcon(isPdf, isDocument, isLink),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getResourceName(resource),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getResourceType(isPdf, isDocument, isLink),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.download_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getResourceColor(bool isPdf, bool isDocument, bool isLink) {
    if (isPdf) return Colors.red;
    if (isDocument) return Colors.blue;
    if (isLink) return Colors.green;
    return Colors.grey;
  }

  IconData _getResourceIcon(bool isPdf, bool isDocument, bool isLink) {
    if (isPdf) return Icons.picture_as_pdf;
    if (isDocument) return Icons.description;
    if (isLink) return Icons.link;
    return Icons.insert_drive_file;
  }

  String _getResourceName(String resource) {
    if (resource.startsWith('http')) {
      return Uri.parse(resource).host;
    }
    return resource.split('/').last;
  }

  String _getResourceType(bool isPdf, bool isDocument, bool isLink) {
    if (isPdf) return 'PDF Document';
    if (isDocument) return 'Word Document';
    if (isLink) return 'External Link';
    return 'File';
  }

  void _handleResourceTap(String resource) {
    if (resource.startsWith('http')) {
      // Open URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening: ${Uri.parse(resource).host}'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              // In a real app, you would use url_launcher here
            },
          ),
        ),
      );
    } else {
      // Download file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading: ${resource.split('/').last}'),
          action: SnackBarAction(
            label: 'Download',
            onPressed: () {
              // In a real app, you would handle file download here
            },
          ),
        ),
      );
    }
  }

  List<String> _getMockResources() {
    return [
      'https://example.com/lesson-notes.pdf',
      'https://example.com/additional-reading.pdf',
      'https://example.com/code-examples.zip',
      'https://github.com/example/repository',
      'https://example.com/video-transcript.pdf',
    ];
  }
}
