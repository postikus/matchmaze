import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import '../models/grid.dart';

class GameField extends Component {
  late final Grid grid;
  final double cellSize = 50.0;

  GameField() {
    grid = Grid();
  }

  @override
  Future<void> onLoad() async {
    // Рассчитываем общий размер сетки
    final totalWidth = grid.width * cellSize;
    final totalHeight = grid.height * cellSize;
    
    // Устанавливаем размер компонента
    size = Vector2(totalWidth, totalHeight);
    
    // Позиционируем игровое поле в центре
    anchor = Anchor.center;
    position = Vector2.zero();
    
    // Инициализируем игровое поле
    await generateField();
  }

  Future<void> generateField() async {
    // TODO: Реализовать логику генерации поля
  }
} 