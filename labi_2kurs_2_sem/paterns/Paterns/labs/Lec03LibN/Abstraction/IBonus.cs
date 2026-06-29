namespace Lec03LibN.Abstraction;
public interface IBonus
{
	float cost1hour {  get; set; }
	float calc(float number_hours);
}
