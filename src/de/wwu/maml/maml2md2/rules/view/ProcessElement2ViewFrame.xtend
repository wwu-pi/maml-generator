package de.wwu.maml.maml2md2.rules.view

import de.wwu.maml.dsl.maml.InteractionProcessElement
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.md2.framework.mD2.Label
import de.wwu.md2.framework.mD2.ViewFrame
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*

class ProcessElement2ViewFrame extends Elem2Elem {
	
	public static final String ruleID = "ProcessElement->ViewFrame"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	 
	/* 
	 * Dependencies:
	 * 
	 */
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(InteractionProcessElement))
			.forEach[src |
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val viewFrame = corr.getOrCreateTargetElem(targetPackage.viewFrame) as ViewFrame
				
				viewFrame.name = src.viewName
				
				// TODO dummy view element
				val viewElem = createTargetElement(targetPackage.label) as Label
				viewElem.text = "Dummy label"
				viewElem.name = viewElem.text.allowedAttributeName
				viewFrame.elements.add(viewElem)
				
				// Attach to container
				MD2ViewContent.add(viewFrame)
			]
	}
	
	override def targetToSource() {
//		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
//			.forEach[m |
//				val corr = m.getOrCreateCorrModelElement(ruleID)
//				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
//				sourceModel.MAMLResource.contents += source
//			]
	}
}