-- Devuelve el identificador y el tipo de la Propuesta de Gasto que tiene seleccionado el check 'Quiero participar en la mesa de zona de mi propuesta.' 
-- y todos los datos del usuario asociado a cada prouesta
SELECT t.budget_investment_id,t.title, u.*
FROM budget_investments b, users u, budget_investment_translations t
WHERE b.zona_mesa is true
AND b.id = t.budget_investment_id
AND u.id =b.author_id;
