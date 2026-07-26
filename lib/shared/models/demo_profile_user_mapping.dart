import '../../core/demo/demo_seed_ids.dart';
import 'demo_user_profile.dart';
const demoProfileUserIds=<String,String>{'employee':DemoSeedIds.ahmed,'manager':DemoSeedIds.sara,'senior':DemoSeedIds.omar,'administrator':DemoSeedIds.laila,'queue':DemoSeedIds.khaled};
String seededUserIdForDemoProfile(DemoUserProfile profile){ final id=demoProfileUserIds[profile.id]; if(id==null) throw StateError('Demo profile ${profile.id} has no seeded user'); return id; }
bool validateDemoProfileMappings()=>demoProfiles.map((p)=>seededUserIdForDemoProfile(p)).toSet().length==demoProfiles.length;
