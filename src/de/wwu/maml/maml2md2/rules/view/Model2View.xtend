package de.wwu.maml.maml2md2.rules.view

import org.eclipse.emf.ecore.resource.Resource
import de.wwu.md2.framework.mD2.PackageDefinition
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation

class Model2View extends Elem2Elem {
	
	public static final String ruleID = "Model->MD2Model[View]"
	
	new(Resource src, Resource trgt, Resource corr) {
		super(src, trgt, corr)
		
	}
	
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(de.wwu.maml.dsl.maml.Model))
			.forEach[m |
				// Create view
				val corrV = m.getOrCreateCorrModelElement(ruleID)
				val targetV = corrV.getOrCreateTargetElem(targetPackage.MD2Model) as de.wwu.md2.framework.mD2.MD2Model
				
				val targetPackageView = createTargetElement(targetPackage.packageDefinition) as PackageDefinition
				targetPackageView.pkgName = Maml2md2Transformation.PACKAGE_NAME + ".views"
				targetV.package = targetPackageView
				
				val targetViewLayer = createTargetElement(targetPackage.view) as de.wwu.md2.framework.mD2.View
				targetV.modelLayer = targetViewLayer
				targetModel.contents += targetV
			]
	}
	
	override def targetToSource() {
		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
			.forEach[m |
				val corr = m.getOrCreateCorrModelElement(ruleID)
				val source = corr.getOrCreateSourceElem(sourcePackage.model)
				sourceModel.contents += source
			]
	}
	
}