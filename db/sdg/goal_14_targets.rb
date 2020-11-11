goal = SDG::Goal.find(14)
if goal && SDG::Target.find_by(goal_id: goal.id).none?
  SDG::Target.create!(title_en: "14.1",
                      description_en: "14.1 By 2025, prevent and significantly reduce marine pollution of all kinds, in particular from land-based activities, including marine debris and nutrient pollution",
                      title_es: "14.1",
                      description_es: "14.1 De aquí a 2025, prevenir y reducir significativamente la contaminación marina de todo tipo, en particular la producida por actividades realizadas en tierra, incluidos los detritos marinos y la polución por nutrientes",
                      goal: goal)

  SDG::Target.create!(title_en: "14.2",
                      description_en: "14.2 By 2020, sustainably manage and protect marine and coastal ecosystems to avoid significant adverse impacts, including by strengthening their resilience, and take action for their restoration in order to achieve healthy and productive oceans",
                      title_es: "14.2",
                      description_es: "14.2 De aquí a 2020, gestionar y proteger sosteniblemente los ecosistemas marinos y costeros para evitar efectos adversos importantes, incluso fortaleciendo su resiliencia, y adoptar medidas para restaurarlos a fin de restablecer la salud y la productividad de los océanos",
                      goal: goal)

  SDG::Target.create!(title_en: "14.3",
                      description_en: "14.3 Minimize and address the impacts of ocean acidification, including through enhanced scientific cooperation at all levels",
                      title_es: "14.3",
                      description_es: "14.3 Minimizar y abordar los efectos de la acidificación de los océanos, incluso mediante una mayor cooperación científica a todos los niveles",
                      goal: goal)

  SDG::Target.create!(title_en: "14.4",
                      description_en: "14.4 By 2020, effectively regulate harvesting and end overfishing, illegal, unreported and unregulated fishing and destructive fishing practices and implement science-based management plans, in order to restore fish stocks in the shortest time feasible, at least to levels that can produce maximum sustainable yield as determined by their biological characteristics",
                      title_es: "14.4",
                      description_es: "14.4 De aquí a 2020, reglamentar eficazmente la explotación pesquera y poner fin a la pesca excesiva, la pesca ilegal, no declarada y no reglamentada y las prácticas pesqueras destructivas, y aplicar planes de gestión con fundamento científico a fin de restablecer las poblaciones de peces en el plazo más breve posible, al menos alcanzando niveles que puedan producir el máximo rendimiento sostenible de acuerdo con sus características biológicas",
                      goal: goal)

  SDG::Target.create!(title_en: "14.5",
                      description_en: "14.5 By 2020, conserve at least 10 per cent of coastal and marine areas, consistent with national and international law and based on the best available scientific information",
                      title_es: "14.5",
                      description_es: "14.5 De aquí a 2020, conservar al menos el 10% de las zonas costeras y marinas, de conformidad con las leyes nacionales y el derecho internacional y sobre la base de la mejor información científica disponible",
                      goal: goal)

  SDG::Target.create!(title_en: "14.6",
                      description_en: "14.6 By 2020, prohibit certain forms of fisheries subsidies which contribute to overcapacity and overfishing, eliminate subsidies that contribute to illegal, unreported and unregulated fishing and refrain from introducing new such subsidies, recognizing that appropriate and effective special and differential treatment for developing and least developed countries should be an integral part of the World Trade Organization fisheries subsidies negotiation",
                      title_es: "14.6",
                      description_es: "14.6 De aquí a 2020, prohibir ciertas formas de subvenciones a la pesca que contribuyen a la sobrecapacidad y la pesca excesiva, eliminar las subvenciones que contribuyen a la pesca ilegal, no declarada y no reglamentada y abstenerse de introducir nuevas subvenciones de esa índole, reconociendo que la negociación sobre las subvenciones a la pesca en el marco de la Organización Mundial del Comercio debe incluir un trato especial y diferenciado, apropiado y efectivo para los países en desarrollo y los países menos adelantados ¹ (¹ Teniendo en cuenta las negociaciones en curso de la Organización Mundial del Comercio, el Programa de Doha para el Desarrollo y el mandato de la Declaración Ministerial de Hong Kong).",
                      goal: goal)

  SDG::Target.create!(title_en: "14.7",
                      description_en: "14.7 By 2030, increase the economic benefits to Small Island developing States and least developed countries from the sustainable use of marine resources, including through sustainable management of fisheries, aquaculture and tourism",
                      title_es: "14.7",
                      description_es: "14.7 De aquí a 2030, aumentar los beneficios económicos que los pequeños Estados insulares en desarrollo y los países menos adelantados obtienen del uso sostenible de los recursos marinos, en particular mediante la gestión sostenible de la pesca, la acuicultura y el turismo",
                      goal: goal)

  SDG::Target.create!(title_en: "14.A",
                      description_en: "14.A Increase scientific knowledge, develop research capacity and transfer marine technology, taking into account the Intergovernmental Oceanographic Commission Criteria and Guidelines on the Transfer of Marine Technology, in order to improve ocean health and to enhance the contribution of marine biodiversity to the development of developing countries, in particular small island developing States and least developed countries",
                      title_es: "14.a",
                      description_es: "14.a Aumentar los conocimientos científicos, desarrollar la capacidad de investigación y transferir tecnología marina, teniendo en cuenta los Criterios y Directrices para la Transferencia de Tecnología Marina de la Comisión Oceanográfica Intergubernamental, a fin de mejorar la salud de los océanos y potenciar la contribución de la biodiversidad marina al desarrollo de los países en desarrollo, en particular los pequeños Estados insulares en desarrollo y los países menos adelantados",
                      goal: goal)

  SDG::Target.create!(title_en: "14.B",
                      description_en: "14.B Provide access for small-scale artisanal fishers to marine resources and markets",
                      title_es: "14.b",
                      description_es: "14.b Facilitar el acceso de los pescadores artesanales a los recursos marinos y los mercados",
                      goal: goal)

  SDG::Target.create!(title_en: "14.C",
                      description_en: "14.C Enhance the conservation and sustainable use of oceans and their resources by implementing international law as reflected in UNCLOS, which provides the legal framework for the conservation and sustainable use of oceans and their resources, as recalled in paragraph 158 of The Future We Want",
                      title_es: "14.c",
                      description_es: "14.c Mejorar la conservación y el uso sostenible de los océanos y sus recursos aplicando el derecho internacional reflejado en la Convención de las Naciones Unidas sobre el Derecho del Mar, que constituye el marco jurídico para la conservación y la utilización sostenible de los océanos y sus recursos, como se recuerda en el párrafo 158 del documento “El futuro que queremos”",
                      goal: goal)
end
